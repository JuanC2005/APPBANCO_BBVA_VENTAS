import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/supabase/supabase_client.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/table_config.dart';
import 'dashboard_screen.dart';
import 'table_list_screen.dart';
import 'admin_login_screen.dart';
import 'admin_role_management_screen.dart';
import 'admin_reportes_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AdminAppWithAuth());
  }
}

class _AdminAppWithAuth extends StatelessWidget {
  const _AdminAppWithAuth();

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
      home: const _AdminGate(),
    );
  }
}

class _AdminGate extends StatefulWidget {
  const _AdminGate();

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  bool _authenticated = false;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
    SupabaseClientProvider.onAuthChange((event) {
      if (event == AuthChangeEvent.signedOut) {
        if (mounted) setState(() => _authenticated = false);
      }
    });
  }

  Future<void> _checkExistingSession() async {
    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session != null &&
        session.expiresAt != null &&
        DateTime.now().isBefore(
            DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000))) {
      setState(() => _authenticated = true);
    }
    if (mounted) setState(() => _checkingSession = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_authenticated) {
      return AdminLoginScreen(
        onLoginSuccess: () => setState(() => _authenticated = true),
      );
    }
    return AdminShell(
      onLogout: () async {
        await SupabaseClientProvider.client.auth.signOut();
        setState(() => _authenticated = false);
      },
    );
  }
}

class AdminShell extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminShell({super.key, required this.onLogout});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _onDashboard = true;
  bool _onRoles = false;
  bool _onReportes = false;
  String? _selectedTable;

  void _goToDashboard() {
    setState(() {
      _onDashboard = true;
      _onRoles = false;
      _onReportes = false;
      _selectedTable = null;
    });
  }

  void _goToRoles() {
    setState(() {
      _onDashboard = false;
      _onRoles = true;
      _onReportes = false;
      _selectedTable = null;
    });
  }

  void _goToReportes() {
    setState(() {
      _onDashboard = false;
      _onRoles = false;
      _onReportes = true;
      _selectedTable = null;
    });
  }

  void _goToTable(String tableName) {
    setState(() {
      _onDashboard = false;
      _onRoles = false;
      _onReportes = false;
      _selectedTable = tableName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail =
        SupabaseClientProvider.client.auth.currentUser?.email ?? 'Admin';

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
                userEmail,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          AdminSidebar(
            onDashboard: _onDashboard,
            onRoles: _onRoles,
            onReportes: _onReportes,
            selectedTable: _selectedTable,
            onDashboardSelected: _goToDashboard,
            onRolesSelected: _goToRoles,
            onReportesSelected: _goToReportes,
            onTableSelected: _goToTable,
            onLogout: widget.onLogout,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _onDashboard
                ? const DashboardScreen()
                : _onRoles
                    ? const AdminRoleManagementScreen()
                    : _onReportes
                        ? const AdminReportesScreen()
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
