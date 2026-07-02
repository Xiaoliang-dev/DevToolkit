import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/github_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1C1B1F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DevToolkitApp());
}

class DevToolkitApp extends StatelessWidget {
  const DevToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevToolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFEF7FF),
          selectedItemColor: Color(0xFF6750A4),
          unselectedItemColor: Color(0xFF49454F),
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF6750A4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF2B2930),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF1C1B1F),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C1B1F),
          selectedItemColor: Color(0xFFD0BCFF),
          unselectedItemColor: Color(0xFF938F99),
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFFD0BCFF),
          foregroundColor: const Color(0xFF381E72),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1B1F),
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ToolsScreen(),
    const GitHubScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.construction_outlined),
      selectedIcon: Icon(Icons.construction),
      label: 'Tools',
    ),
    const NavigationDestination(
      icon: Icon(Icons.code_outlined),
      selectedIcon: Icon(Icons.code),
      label: 'GitHub',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        backgroundColor: isDark ? const Color(0xFF1C1B1F) : const Color(0xFFFEF7FF),
        indicatorColor: isDark ? const Color(0xFF4A4458) : const Color(0xFFE8DEF8),
      ),
    );
  }
}
