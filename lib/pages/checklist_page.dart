import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "../tools/checklist_logic.dart";

/// Checklist — little everyday lists, saved on the device.
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const _key = "checklist.items";

  final _add = TextEditingController();
  List<ChecklistItem> _items = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _items = ChecklistMath.ordered([
        for (final j in DataStore.getList(
          _key,
        ).whereType<Map<String, dynamic>>())
          ChecklistItem.fromJson(j),
      ]);
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    await DataStore.setList(_key, [for (final i in _items) i.toJson()]);
  }

  Future<void> _addItem(String text) async {
    text = text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items = [
        ..._items,
        ChecklistItem(text: text, createdAt: DateTime.now().toIso8601String()),
      ];
      _add.clear();
    });
    await _persist();
  }

  Future<void> _toggle(int idx) async {
    setState(() {
      _items = [
        for (var i = 0; i < _items.length; i++)
          i == idx ? _items[i].copyWith(done: !_items[i].done) : _items[i],
      ];
    });
    await _persist();
  }

  Future<void> _delete(int idx) async {
    setState(() {
      _items = [
        for (var i = 0; i < _items.length; i++)
          if (i != idx) _items[i],
      ];
    });
    await _persist();
  }

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = ChecklistMath.count(_items);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
        actions: [
          if (count.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Chip(
                label: Text(count),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_items.isNotEmpty) ...[
                  LinearProgressIndicator(
                    value: ChecklistMath.progress(_items),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: theme.colorScheme.surface,
                    color: UniroidTheme.pink,
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _add,
                  decoration: const InputDecoration(
                    hintText: "Add something to tick off…",
                  ),
                  onSubmitted: _addItem,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _items.length; i++)
                  Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: _items[i].done,
                        activeColor: UniroidTheme.pink,
                        onChanged: (_) => _toggle(i),
                      ),
                      title: Text(
                        _items[i].text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: _items[i].done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: _items[i].done
                              ? theme.textTheme.bodySmall?.color
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _delete(i),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
