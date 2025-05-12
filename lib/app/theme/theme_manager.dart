// lib/app/theme/theme_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends StatefulWidget {
  final Widget child;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeManager({
    Key? key,
    required this.child,
    required this.lightTheme,
    required this.darkTheme,
  }) : super(key: key);

  @override
  ThemeManagerState createState() => ThemeManagerState();

  static ThemeManagerState of(BuildContext context) {
    final ThemeManagerState? result =
    context.findAncestorStateOfType<ThemeManagerState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'ThemeManager.of() called with a context that does not contain a ThemeManager.'),
    ]);
  }
}

class ThemeManagerState extends State<ThemeManager> {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void changeTheme(bool isDarkMode) async {
    // Add print statements for debugging
    print("Changing theme to isDarkMode: $isDarkMode");

    // Ensure we're actually changing the state
    if (_isDarkMode != isDarkMode) {
      setState(() {
        _isDarkMode = isDarkMode;
      });

      // Add delay before saving to preferences to avoid race conditions
      await Future.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);

      print("Theme changed. New isDarkMode: $_isDarkMode");
    } else {
      print("Theme state unchanged - already $_isDarkMode");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add a print statement to verify theme state during builds
    print("Building ThemeManager with isDarkMode: $_isDarkMode");

    return Theme(
      data: _isDarkMode ? widget.darkTheme : widget.lightTheme,
      child: widget.child,
    );
  }
}