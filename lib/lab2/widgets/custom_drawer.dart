import 'package:flutter/material.dart';

import 'package:moblabs/lab2/elements/responsive_config.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu'),
          ),
          ListTile(
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: ResponsiveConfig.contentFontSize(context),
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: ResponsiveConfig.drawerFontSize(context),
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
