import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/providers/theme_provider/theme_provider.dart';
import 'package:whiskr_admin_panel/providers/auth_provider.dart';

class WebDrawer extends StatelessWidget {
  const WebDrawer({super.key, required this.selectedIndex, required this.onItemTapped, required this.onShowPlaceholderDialog, required this.isPetShop});

  final int selectedIndex;
  final Function(int) onItemTapped;
  final Function(String, String) onShowPlaceholderDialog;
  final bool isPetShop;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [ColorHelper.darkThemeBackground.color, ColorHelper.blue700.color])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  color: !context.read<CustomThemeProvider>().isDarkTheme(context)
                      ? ColorHelper.darkThemeBackground.color
                      : ColorHelper.lightThemeBackground.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Image.asset('assets/images/appicon.png', width: 60, height: 60),
                ),
                const SizedBox(height: 12),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.currentUser?.name ?? 'Admin User',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.currentUser?.email ?? 'admin@whiskr.com',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
            selectedColor: ColorHelper.blue500.color,
          ),
          _buildRoleAwareDrawerItem(context),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Orders'),
            selected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
            selectedColor: ColorHelper.blue500.color,
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            selected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
            selectedColor: ColorHelper.blue500.color,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selectedColor: ColorHelper.blue500.color,
            onTap: () {
              onShowPlaceholderDialog('Settings', 'Settings functionality coming sooon!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            selectedColor: ColorHelper.blue500.color,
            onTap: () {
              onShowPlaceholderDialog('Help & Support', 'Help & Support functionality coming soon!');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleAwareDrawerItem(BuildContext context) {
    return ListTile(
      leading: Icon(isPetShop ? Icons.room_service : Icons.inventory),
      title: Text(isPetShop ? 'Services Offered' : 'Inventory'),
      selected: selectedIndex == 1,
      onTap: () => onItemTapped(1),
    );
  }
}
