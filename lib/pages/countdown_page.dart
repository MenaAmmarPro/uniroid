import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "../tools/countdown_logic.dart";

/// "Our Countdown" — the days-together counter with milestones.
class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  static const _startKey = "countdown.start";
  late String _start = DataStore.getString(
    _startKey,
    CountdownMath.defaultStart,
  );

  int? _days;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  void _recompute() {
    final now = DateTime.now();
    setState(() {
      _days = CountdownMath.daysBetween(
        _start,
        "${now.year.toString().padLeft(4, "0")}-"
        "${now.month.toString().padLeft(2, "0")}-"
        "${now.day.toString().padLeft(2, "0")}",
      );
    });
  }

  Future<void> _pickStart() async {
    final initial = DateTime.tryParse(_start) ?? DateTime(2026, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: "When did it all begin?",
    );
    if (picked == null) return;
    final iso =
        "${picked.year.toString().padLeft(4, "0")}-"
        "${picked.month.toString().padLeft(2, "0")}-"
        "${picked.day.toString().padLeft(2, "0")}";
    await DataStore.setString(_startKey, iso);
    setState(() => _start = iso);
    _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final next = days == null ? null : CountdownMath.nextMilestone(days);
    final current = days == null ? null : CountdownMath.currentMilestone(days);
    final theme = Theme.of(context);

    final Widget bigNumber;
    if (days == null) {
      bigNumber = Text("—", style: theme.textTheme.displayLarge);
    } else if (days < 0) {
      bigNumber = Text(
        "${-days}",
        style: theme.textTheme.displayLarge?.copyWith(color: UniroidTheme.pink),
      );
    } else {
      bigNumber = Text(
        "$days",
        style: theme.textTheme.displayLarge?.copyWith(
          color: UniroidTheme.pink,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Countdown"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: "Change the day",
            onPressed: _pickStart,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    days != null && days < 0
                        ? "days until it begins"
                        : "days together",
                    style: theme.textTheme.bodySmall,
                  ),
                  bigNumber,
                  const SizedBox(height: 4),
                  Text("since $_start", style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (next != null && days != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next milestone: ${next.value}",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${next.key - days} days to go",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: CountdownMath.progress(
                        current?.key ?? 0,
                        next.key,
                        days,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: theme.colorScheme.surface,
                      color: UniroidTheme.pink,
                    ),
                    if (current != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Last reached: ${current.value}",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("All milestones", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final mark in CountdownMath.milestoneMarks)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            days != null && days >= mark
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: UniroidTheme.pink,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            CountdownMath.labelFor(mark),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            days == null
                                ? "—"
                                : days >= mark
                                ? "reached"
                                : "in ${mark - days} days",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
