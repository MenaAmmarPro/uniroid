import "package:flutter/material.dart";

import "data_store.dart";
import "pages/shell.dart";
import "theme.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStore.init();
  final dark = DataStore.darkMode ?? true;
  runApp(UniroidApp(initialDark: dark));
}

class UniroidApp extends StatefulWidget {
  const UniroidApp({super.key, required this.initialDark});

  /// null means "follow the system".
  final bool initialDark;

  @override
  UniroidAppState createState() => UniroidAppState();
}

class UniroidAppState extends State<UniroidApp> {
  late bool _dark = widget.initialDark;

  bool get isDark => _dark;

  /// Toggles dark/light and remembers the choice.
  Future<void> setDark(bool dark) async {
    setState(() => _dark = dark);
    await DataStore.setDarkMode(dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Uniroid",
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: UniroidTheme.light(),
      darkTheme: UniroidTheme.dark(),
      home: const Shell(),
    );
  }
}
