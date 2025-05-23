import 'package:dz_admin_panel/screens/dashboard_screen/components/dashboard_summaryCard.dart';
import 'package:dz_admin_panel/screens/dashboard_screen/components/serviceTableScreen.dart';
import 'package:dz_admin_panel/screens/dashboard_screen/components/userTableScreen.dart';
import 'package:dz_admin_panel/service/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> counts = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final fetchedCounts = await FirestoreService.fetchDashboardCounts();
    setState(() {
      counts = fetchedCounts;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount =
        width > 1440
            ? 5
            : width > 1200
            ? 4
            : width > 800
            ? 3
            : width > 600
            ? 2
            : 1;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          DashboardCard(
            title: "Total Users",
            icon: Icons.people,
            count: counts['users'] ?? 0,
            color: Colors.blue,
            graphData: [10, 20, 15, 30, 40, 35, 50],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersTableScreen()),
              );
            },
          ),
          DashboardCard(
            title: "Pending Orders",
            icon: Icons.shopping_cart,
            count: counts['orders'] ?? 0,
            color: Colors.teal,
            graphData: [5, 10, 15, 12, 20, 18, 25],
            onTap: () {},
          ),
          DashboardCard(
            title: "Services",
            icon: Icons.design_services,
            count: counts['services'] ?? 0,
            color: Colors.orange,
            graphData: [3, 6, 9, 7, 10, 11, 14],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceScreen()),
              );
            },
          ),
          DashboardCard(
            title: "Reviews",
            icon: Icons.reviews,
            count: counts['reviews'] ?? 0,
            color: Colors.purple,
            graphData: [1, 2, 4, 3, 5, 6, 7],
            onTap: () {
              // Your onTap code here
            },
          ),
          DashboardCard(
            title: "Contact Requests",
            icon: Icons.contact_mail,
            count: counts['contactRequests'] ?? 0,
            color: Colors.red,
            graphData: [2, 1, 3, 4, 2, 3, 5],
            onTap: () {
              // Your onTap code here
            },
          ),
        ],
      ),
    );
  }
}
