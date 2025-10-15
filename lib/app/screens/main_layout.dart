import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:w_utils/color_helper/color_helper.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final _sideMenuController = SideMenuController();

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.dashboard, label: 'Dashboard'),
    MenuItem(icon: Icons.analytics, label: 'Analytics'),
    MenuItem(icon: Icons.folder, label: 'Projects'),
    MenuItem(icon: Icons.people, label: 'Team'),
    MenuItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  void dispose() {
    _sideMenuController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Menu using flutter_side_menu package
          SideMenu(
            controller: _sideMenuController,
            mode: SideMenuMode.open,
            hasResizer: false,
            hasResizerToggle: true,
            minWidth: 75,
            maxWidth: 250,
            backgroundColor: ColorHelper.lightThemeBackground.color,
            resizerToggleData: ResizerToggleData(topPosition: 10, iconColor: ColorHelper.darkThemeBackground.color, iconSize: 22),
            builder: (data) => SideMenuData(header: const _BuildHeader(), items: _buildMenuItems()),
          ),
          // Main Content Area
          Expanded(
            child: Container(color: ColorHelper.darkThemeBackground.color, child: widget.child),
          ),
        ],
      ),
    );
  }

  List<SideMenuItemDataTile> _buildMenuItems() {
    return _menuItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = _selectedIndex == index;
      final theme = Theme.of(context);
      return SideMenuItemDataTile(
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        title: item.label,
        titleStyle: theme.textTheme.bodyMedium!.copyWith(
          color: !isSelected ? ColorHelper.darkThemeBackground.color : ColorHelper.lightThemeBackground.color,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        icon: Icon(item.icon, color: ColorHelper.greenWeb.color, size: 20),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        hoverColor: Colors.white.withOpacity(0.05),
      );
    }).toList();
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.asset('assets/images/appicon.png', width: 40, height: 40),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}
