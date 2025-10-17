import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final SideMenuController _sideMenuController = SideMenuController();
  bool _isSideMenuOpen = true; // Track menu state

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.dashboard, label: 'Dashboard', route: dashboardRoute),
    MenuItem(icon: Icons.analytics, label: 'Inventory', route: inventoryRoute),
    MenuItem(icon: Icons.folder, label: 'Orders', route: ordersRoute),
    MenuItem(icon: Icons.people, label: 'Analytics', route: analyticsRoute),
    MenuItem(icon: Icons.settings, label: 'Settings', route: settingsRoute),
  ];

  void _toggleSideMenu() {
    setState(() {
      _isSideMenuOpen = !_isSideMenuOpen;
      if (_isSideMenuOpen) {
        _sideMenuController.open();
      } else {
        _sideMenuController.close();
      }
    });
  }

  @override
  void dispose() {
    _sideMenuController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, mounted, _toggleSideMenu, _isSideMenuOpen),
      body: Row(
        children: [
          SideMenu(
            controller: _sideMenuController,
            mode: SideMenuMode.open,
            hasResizer: false,
            hasResizerToggle: false, // Disable built-in toggle
            minWidth: 75,
            maxWidth: 250,
            backgroundColor: ColorHelper.white.color,
            builder: (data) => SideMenuData(items: _buildMenuItems()),
          ),
          // Main Content Area
          Expanded(child: Container(child: widget.child)),
        ],
      ),
    );
  }

  List<SideMenuItemDataTile> _buildMenuItems() {
    return _menuItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final String route = item.route;
      final isSelected = _selectedIndex == index;
      final theme = Theme.of(context);
      return SideMenuItemDataTile(
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          context.go(route);
        },
        title: item.label,
        titleStyle: theme.textTheme.bodyMedium,
        selectedTitleStyle: theme.textTheme.bodyMedium!.copyWith(color: ColorHelper.white.color, fontWeight: FontWeight.bold),
        icon: Icon(item.icon, color: isSelected ? ColorHelper.white.color : ColorHelper.greenWeb.color, size: 20),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        hoverColor: ColorHelper.greenWeb.color.withAlpha(140),
        hasSelectedLine: false,
        highlightSelectedColor: ColorHelper.greenWeb.color,
      );
    }).toList();
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, bool mounted, VoidCallback onMenuToggle, bool isSideMenuOpen) {
  return AppBar(
    backgroundColor: ColorHelper.white.color,
    toolbarHeight: 60,
    leading: Row(
      children: [
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(isSideMenuOpen ? Icons.menu_open : Icons.menu, color: ColorHelper.greenWeb.color),
          onPressed: onMenuToggle,
          tooltip: 'Toggle Menu',
        ),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Image.asset('assets/images/appicon.png', width: 40, height: 40),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.asset('assets/images/WhiskrLogo.png', width: 100, height: 100),
          ),
        ),
      ],
    ),
    leadingWidth: Responsive.value(context: context, mobile: 250, tablet: 250, desktop: 250, widescreen: 250),
    actions: [_BuildActionProfile()],
  );
}

class _BuildActionProfile extends StatelessWidget {
  const _BuildActionProfile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png')),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eric Cartman', style: theme.textTheme.bodyMedium),
            Text('Admin', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;
  final String route;

  MenuItem({required this.icon, required this.label, this.route = ""});
}
