"use strict";

/*
 * uniroid — launcher icon generator (run once).
 *
 *   node tools/make-icons.js
 *
 * Dependency-free PNG encoder (zlib + CRC32): a white heart on a pink
 * rounded square, written straight into the Android mipmaps.
 */

const fs = require("fs");
const zlib = require("zlib");
const path = require("path");

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(t, d) {
  const l = Buffer.alloc(4);
  l.writeUInt32BE(d.length, 0);
  const ty = Buffer.from(t, "ascii");
  const cr = Buffer.alloc(4);
  cr.writeUInt32BE(crc32(Buffer.concat([ty, d])), 0);
  return Buffer.concat([l, ty, d, cr]);
}

function png(size, fn) {
  const raw = Buffer.alloc(size * (size * 4 + 1));
  let o = 0;
  for (let y = 0; y < size; y++) {
    raw[o++] = 0;
    for (let x = 0; x < size; x++) {
      const p = fn(x, y, size);
      raw[o++] = p[0];
      raw[o++] = p[1];
      raw[o++] = p[2];
      raw[o++] = p[3];
    }
  }
  const ih = Buffer.alloc(13);
  ih.writeUInt32BE(size, 0);
  ih.writeUInt32BE(size, 4);
  ih[8] = 8;
  ih[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", ih),
    chunk("IDAT", zlib.deflateSync(raw, { level: 9 })),
    chunk("IEND", Buffer.alloc(0))
  ]);
}

function heart(x, y, size) {
  const nx = (x + 0.5) / size * 2 - 1;
  const ny = 1 - (y + 0.5) / size * 2;
  const X = nx * 1.25;
  const Y = ny * 1.25 + 0.12;
  return Math.pow(X * X + Y * Y - 1, 3) - X * X * Math.pow(Y, 3) <= 0;
}

function roundedSquare(x, y, size, radiusFrac) {
  const r = size * radiusFrac;
  const dx = Math.min(x, size - 1 - x);
  const dy = Math.min(y, size - 1 - y);
  if (dx >= r || dy >= r) return true;
  const cx = r - dx;
  const cy = r - dy;
  return cx * cx + cy * cy <= r * r;
}

const PINK = [233, 30, 99, 255];
const WHITE = [255, 255, 255, 255];
const CLEAR = [255, 255, 255, 0];

const res = path.join(__dirname, "..", "android", "app", "src", "main", "res");
const sizes = {
  "mipmap-mdpi": 48,
  "mipmap-hdpi": 72,
  "mipmap-xhdpi": 96,
  "mipmap-xxhdpi": 144,
  "mipmap-xxxhdpi": 192,
};

for (const [dir, s] of Object.entries(sizes)) {
  const px = png(s, (x, y, size) =>
    roundedSquare(x, y, size, 0.22)
      ? (heart(x, y, size) ? WHITE : PINK)
      : CLEAR
  );
  fs.writeFileSync(path.join(res, dir, "ic_launcher.png"), px);
  console.log(`${dir}/ic_launcher.png (${s}px)`);
}
console.log("launcher icons written");
