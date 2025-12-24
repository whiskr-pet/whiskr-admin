import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/helpers/main_layout_menu_item.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
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
  bool isTypeShop = false;

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
    final bool type = await ServiceTypeService.getServiceType();
    setState(() {
      isTypeShop = type;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: ColorHelper.white.color,
            builder: (data) => SideMenuData(items: _buildMenuItems(isTypeShop)),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  List<SideMenuItemDataTile> _buildMenuItems(bool isTypeShop) {
    return _menuItems(isTypeShop: isTypeShop).asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final String route = item.route;
      final isSelected = context.read<DashboardProvider>().isSelectedIndexEqualTo(index);
      final theme = Theme.of(context);
      return SideMenuItemDataTile(
        isSelected: isSelected,
        onTap: () {
          context.read<DashboardProvider>().setSelectedIndex(index);
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

PreferredSizeWidget _buildAppBar(BuildContext context, bool mounted, VoidCallback onMenuToggle) {
  return AppBar(
    backgroundColor: ColorHelper.white.color,
    toolbarHeight: 60,
    leading: Row(
      children: [
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(context.watch<DashboardProvider>().isSideMenuOpen ? Icons.menu_open : Icons.menu, color: ColorHelper.greenWeb.color),
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
    final theme = Theme.of(context);
    return Consumer<WAOnboardingProvider>(
      builder: (context, provider, _) => Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(provider.serviceAdminData.serviceProfileImage?.url ?? '')),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(provider.serviceAdminData.contact?.email ?? '', style: theme.textTheme.bodyMedium),
              Text('Admin', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }
}
