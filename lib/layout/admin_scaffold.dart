import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatefulWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final sidePanelWidth = screenWidth * (screenWidth > 1200 ? 0.15 : 0.2);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Logo & Name
            Row(
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white),
                SizedBox(width: 8),
                Text("Admin Panel"),
              ],
            ),

            // Right Side
            if (isLargeScreen)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // TODO: Handle notifications
                    },
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/avatar.png',
                    ), // or NetworkImage(...)
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go(
                            '/login',
                          ); // or pushReplacementNamed if using Navigator
                        }
                      } catch (e) {
                        // Optionally show an error
                        print("Logout failed: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to logout. Try again.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // TODO: Handle notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ],
              ),
          ],
        ),
      ),

      drawer:
          isLargeScreen
              ? null
              : Drawer(
                width: screenWidth * 0.6,
                child: Column(
                  children: [
                    // Drawer Header
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Color(0xFF1E1E2C)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png'),
                            radius: 24,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Username",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Navigation
                    Expanded(
                      child: _SidePanel(
                        width: screenWidth * 0.5,
                        isDrawer: true,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Notifications"),
                      onTap: () {
                        // TODO: Handle
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: () {
                        // TODO: Handle logout
                      },
                    ),
                  ],
                ),
              ),

      body: Row(
        children: [
          if (isLargeScreen) _SidePanel(width: sidePanelWidth, isDrawer: false),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  final double width;
  final bool isDrawer;
  final VoidCallback? onClose;

  const _SidePanel({required this.width, this.isDrawer = false, this.onClose});

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        GoRouter.of(context).routeInformationProvider.value.location;

    return Container(
      width: width,
      height: double.infinity,
      color: const Color(0xFF1E1E2C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDrawer)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ),
          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: currentRoute.startsWith('/dashboard'),
            onTap: () {
              context.go('/dashboard');
              if (isDrawer) onClose?.call();
            },
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            selected: currentRoute.startsWith('/settings'),
            onTap: () {
              context.go('/settings');
              if (isDrawer) onClose?.call();
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2D2D3A) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
