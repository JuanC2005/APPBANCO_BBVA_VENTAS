import 'package:flutter/material.dart';
import 'table_config.dart';
import '../../../core/constants/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final String? selectedTable;
  final bool onDashboard;
  final ValueChanged<String> onTableSelected;
  final VoidCallback onDashboardSelected;

  const AdminSidebar({
    super.key,
    this.selectedTable,
    this.onDashboard = true,
    required this.onTableSelected,
    required this.onDashboardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1A2A3A),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  selected: onDashboard,
                  onTap: onDashboardSelected,
                ),
                const Divider(color: Colors.white24, height: 1),
                ..._buildCategorySections(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1A2E),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BBVAColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin BBVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Panel de Control',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    final widgets = <Widget>[];
    for (final category in DatabaseTables.categories) {
      final tables = DatabaseTables.getByCategory(category);
      widgets.add(
        _buildCategoryHeader(category, Icons.category),
      );
      for (final table in tables) {
        widgets.add(
          _buildMenuItem(
            icon: table.icon,
            title: table.displayName,
            selected: !onDashboard && selectedTable == table.tableName,
            onTap: () => onTableSelected(table.tableName),
            indent: true,
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    bool indent = false,
  }) {
    return Material(
      color: selected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.only(
            left: indent ? 32.0 : 16.0,
            right: 16,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? BBVAColors.primaryBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? BBVAColors.lightBlue : Colors.white54,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (selected)
                const Spacer(),
              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: BBVAColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
