import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/table_config.dart';
import 'dashboard_screen.dart';
import 'table_list_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin BBVA Fuerza de Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: BBVAColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: BBVAColors.primaryBlue,
          primary: BBVAColors.primaryBlue,
          secondary: BBVAColors.accentBlue,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: BBVAColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AdminShell(),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _onDashboard = true;
  String? _selectedTable;

  void _goToDashboard() {
    setState(() {
      _onDashboard = true;
      _selectedTable = null;
    });
  }

  void _goToTable(String tableName) {
    setState(() {
      _onDashboard = false;
      _selectedTable = tableName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _onDashboard
              ? 'Panel Administrativo BBVA'
              : _getTableDisplayName(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                'BBVA Fuerza de Ventas',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          AdminSidebar(
            onDashboard: _onDashboard,
            selectedTable: _selectedTable,
            onDashboardSelected: _goToDashboard,
            onTableSelected: _goToTable,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _onDashboard
                ? const DashboardScreen()
                : (_selectedTable != null
                    ? TableListScreen(
                        key: ValueKey(_selectedTable),
                        tableName: _selectedTable!,
                      )
                    : const DashboardScreen()),
          ),
        ],
      ),
    );
  }

  String _getTableDisplayName() {
    if (_selectedTable == null) return 'Panel Administrativo BBVA';
    final config = DatabaseTables.getByTableName(_selectedTable!);
    return config?.displayName ?? _selectedTable!;
  }
}
