import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/helpers/main_layout_menu_item.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final SideMenuController _sideMenuController = SideMenuController();

  List<MenuItem> _menuItems({required bool isTypeShop}) => [
    MenuItem(icon: Icons.dashboard, label: 'Dashboard', route: dashboardRoute),
    MenuItem(icon: Icons.analytics, label: isTypeShop ? 'Inventory' : 'Services', route: inventoryRoute),
    MenuItem(icon: Icons.folder, label: isTypeShop ? 'Orders' : 'Appointments', route: ordersRoute),
    MenuItem(icon: Icons.people, label: 'Analytics', route: analyticsRoute),
    MenuItem(icon: Icons.settings, label: 'Settings', route: settingsRoute),
  ];

  void _toggleSideMenu() {
    context.read<DashboardProvider>().toggleSideMenu();
    final bool isSideMenuOpen = context.read<DashboardProvider>().isSideMenuOpen;
    if (isSideMenuOpen) {
      _sideMenuController.open();
    } else {
      _sideMenuController.close();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getInitialData();
    });
  }

  Future<void> _getInitialData() async {
    final DashboardProvider dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.fetchAndSetServiceType();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Selector<DashboardProvider, bool>(
      selector: (context, provider) => provider.isPetShop,
      builder: (context, isPetShop, child) {
        return Scaffold(
          appBar: _buildAppBar(context, mounted, _toggleSideMenu),
          body: Row(
            children: [
              SideMenu(
                controller: _sideMenuController,
                mode: SideMenuMode.open,
                hasResizer: false,
                hasResizerToggle: false,
                minWidth: 75,
                maxWidth: 250,
                backgroundColor: themeData.colorScheme.surface,
                builder: (data) => SideMenuData(items: _buildMenuItems(isPetShop)),
              ),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }

  List<SideMenuItemDataTile> _buildMenuItems(bool isTypeShop) {
    return _menuItems(isTypeShop: isTypeShop).asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final String route = item.route;
      final isSelected = context.read<DashboardProvider>().isSelectedIndexEqualTo(index);
      final ThemeData themeData = Theme.of(context);
      final ColorScheme colorScheme = themeData.colorScheme;
      return SideMenuItemDataTile(
        isSelected: isSelected,
        onTap: () {
          context.read<DashboardProvider>().setSelectedIndex(index);
          context.go(route);
        },
        title: item.label,
        titleStyle: themeData.textTheme.bodyMedium,
        selectedTitleStyle: themeData.textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
        icon: Icon(item.icon, color: isSelected ? colorScheme.onPrimary : colorScheme.primary, size: 20),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        hoverColor: colorScheme.primary.withValues(alpha: 0.55),
        hasSelectedLine: false,
        highlightSelectedColor: colorScheme.primary,
      );
    }).toList();
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, bool mounted, VoidCallback onMenuToggle) {
  final ThemeData themeData = Theme.of(context);
  final ColorScheme colorScheme = themeData.colorScheme;
  return AppBar(
    backgroundColor: colorScheme.surface,
    toolbarHeight: 60,
    leading: Row(
      children: [
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(context.watch<DashboardProvider>().isSideMenuOpen ? Icons.menu_open : Icons.menu, color: colorScheme.primary),
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
            child: Image.asset('assets/images/WhiskrLogo.png'),
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
    final ThemeData themeData = Theme.of(context);
    return Consumer<WAOnboardingProvider>(
      builder: (context, provider, _) => Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(provider.serviceAdminData.serviceProfileImage?.url ?? '')),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(provider.serviceAdminData.contact?.email ?? '', style: themeData.textTheme.bodyMedium),
              Text('Admin', style: themeData.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }
}
