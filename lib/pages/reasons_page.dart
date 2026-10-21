import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "../tools/reasons_logic.dart";

/// "65 Reasons" — one reason a day + the whole list to browse.
class ReasonsPage extends StatefulWidget {
  const ReasonsPage({super.key});

  @override
  State<ReasonsPage> createState() => _ReasonsPageState();
}

class _ReasonsPageState extends State<ReasonsPage> {
  static const _favKey = "reasons.favorites";

  List<String> _reasons = const [];
  Set<String> _favorites = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _reasons = await DataStore.loadStrings("reasons");
    final raw = DataStore.getList(_favKey);
    setState(() {
      _favorites = {for (final v in raw) v.toString()};
      _loaded = true;
    });
  }

  Future<void> _toggleFav(String reason) async {
    final next = Set<String>.from(_favorites);
    if (next.contains(reason)) {
      next.remove(reason);
    } else {
      next.add(reason);
    }
    await DataStore.setList(_favKey, next.toList());
    setState(() => _favorites = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayReason = ReasonsMath.forDay(_reasons, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("65 Reasons"),
        actions: [
          if (_favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Chip(
                avatar: Icon(
                  Icons.favorite,
                  size: 16,
                  color: UniroidTheme.pink,
                ),
                label: Text("${_favorites.length}"),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today, ${_reasons.isEmpty ? "" : (ReasonsMath.indexForDay(_reasons.length, DateTime.now()) + 1).toString().padLeft(2, "0")}/65",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayReason,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (todayReason.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              _favorites.contains(todayReason)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: UniroidTheme.pink,
                            ),
                            tooltip: "Add to favourites",
                            onPressed: () => _toggleFav(todayReason),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("All of them", style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                for (var i = 0; i < _reasons.length; i++)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _favorites.contains(_reasons[i])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: UniroidTheme.pink,
                      ),
                      title: Text(
                        _reasons[i],
                        style: theme.textTheme.bodyMedium,
                      ),
                      onTap: () => _toggleFav(_reasons[i]),
                    ),
                  ),
              ],
            ),
    );
  }
}
