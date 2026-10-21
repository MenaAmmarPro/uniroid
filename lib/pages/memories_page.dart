import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";

/// Memory Jar — shake (tap) for a random memory from our jar.
class MemoriesPage extends StatefulWidget {
  const MemoriesPage({super.key});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Map<String, dynamic>> _memories = const [];
  Map<String, dynamic>? _current;
  int? _currentIndex;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _memories = await DataStore.loadMaps("memories");
    setState(() {
      _loaded = true;
      if (_memories.isNotEmpty) _draw();
    });
  }

  void _draw() {
    final i = DateTime.now().millisecondsSinceEpoch % _memories.length;
    setState(() {
      _currentIndex = i;
      _current = _memories[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Memory Jar")),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _draw,
                      child: Card(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _current == null
                                    ? "The jar is empty"
                                    : (_current!["date"] ?? "").toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _current == null
                                    ? "—"
                                    : (_current!["text"] ?? "").toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _memories.isEmpty
                          ? ""
                          : _currentIndex == null
                          ? "Tap the jar"
                          : "memory ${_currentIndex! + 1} of ${_memories.length}",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _draw,
                      icon: const Icon(Icons.local_cafe),
                      label: const Text("Draw a memory"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
