// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dz_admin_panel/core/size_cons.dart';
// import 'package:flutter/material.dart';

// class UsersTableScreen extends StatefulWidget {
//   const UsersTableScreen({super.key});

//   @override
//   State<UsersTableScreen> createState() => _UsersTableScreenState();
// }

// class _UsersTableScreenState extends State<UsersTableScreen> {
//   bool loading = true;
//   List<UserWithOrderCount> usersWithOrders = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsersAndOrders();
//   }

//   Future<void> _fetchUsersAndOrders() async {
//     final usersSnapshot =
//         await FirebaseFirestore.instance.collection('users').get();
//     List<UserWithOrderCount> tempList = [];

//     for (var userDoc in usersSnapshot.docs) {
//       final userId = userDoc.id;
//       final userData = userDoc.data();

//       final ordersSnapshot =
//           await FirebaseFirestore.instance
//               .collection('orders')
//               .doc(userId)
//               .collection('orderDetail')
//               .get();

//       // Count orders where status != 'cancel'
//       int activeOrdersCount =
//           ordersSnapshot.docs
//               .where((orderDoc) => orderDoc.data()['status'] != 'cancel')
//               .length;

//       // Sum amounts where status == 'done'
//       int totalAmountDone = 0;
//       for (var orderDoc in ordersSnapshot.docs) {
//         var data = orderDoc.data();
//         if (data['status'] == 'done') {
//           // Make sure amount is a number, fallback 0 if not present
//           int amount = 0;
//           if (data['totalAmount'] != null) {
//             // amount could be int or double in Firestore
//             amount =
//                 (data['totalAmount'] is int)
//                     ? (data['totalAmount'] as int)
//                     : (data['totalAmount'] is int)
//                     ? data['totalAmount'] as int
//                     : 0;
//           }
//           totalAmountDone += amount;
//         }
//       }

//       tempList.add(
//         UserWithOrderCount(
//           userId: userId,
//           email: userData['email'] ?? '',
//           name: userData['name'] ?? '',
//           totalOrders: activeOrdersCount,
//           isActive: userData['active'] ?? true,
//           totalAmount: totalAmountDone,
//         ),
//       );
//     }

//     setState(() {
//       usersWithOrders = tempList;
//       loading = false;
//     });
//   }

//   Future<void> _toggleUserActiveStatus(String userId, bool newStatus) async {
//     await FirebaseFirestore.instance.collection('users').doc(userId).update({
//       'active': newStatus,
//     });
//     setState(() {
//       usersWithOrders =
//           usersWithOrders.map((user) {
//             if (user.userId == userId) {
//               return user.copyWith(isActive: newStatus);
//             }
//             return user;
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: Text("Users")),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth > 1000; // threshold, adjust as needed

//     return Scaffold(
//       appBar: AppBar(title: const Text("Users")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minWidth: isLargeScreen ? screenWidth * 0.7 : 0.8,
//               maxWidth: isLargeScreen ? screenWidth * 0.8 : 0.8,
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: const Color(0xFF1E1E2C),
//               ),
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('Email')),
//                   DataColumn(label: Text('Name')),
//                   DataColumn(label: Text('Total Orders')),
//                   DataColumn(label: Text('Total Amount')),
//                   DataColumn(label: Text('Active')),
//                 ],
//                 rows:
//                     usersWithOrders.map((user) {
//                       return DataRow(
//                         cells: [
//                           DataCell(Text(user.email)),
//                           DataCell(Text(user.name)),
//                           DataCell(Text(user.totalOrders.toString())),
//                           DataCell(
//                             Text('\$${user.totalAmount.toStringAsFixed(0)}'),
//                           ),
//                           DataCell(
//                             Switch(
//                               value: user.isActive,
//                               onChanged:
//                                   (value) => _toggleUserActiveStatus(
//                                     user.userId,
//                                     value,
//                                   ),
//                             ),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class UserWithOrderCount {
//   final String userId;
//   final String email;
//   final String name;
//   final int totalOrders;
//   final bool isActive;
//   final int totalAmount; // new field

//   UserWithOrderCount({
//     required this.userId,
//     required this.email,
//     required this.name,
//     required this.totalOrders,
//     required this.isActive,
//     required this.totalAmount,
//   });

//   UserWithOrderCount copyWith({bool? isActive}) {
//     return UserWithOrderCount(
//       userId: userId,
//       email: email,
//       name: name,
//       totalOrders: totalOrders,
//       isActive: isActive ?? this.isActive,
//       totalAmount: totalAmount,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dz_admin_panel/core/size_cons.dart';
import 'package:flutter/material.dart';

class UsersTableScreen extends StatefulWidget {
  const UsersTableScreen({super.key});

  @override
  State<UsersTableScreen> createState() => _UsersTableScreenState();
}

class _UsersTableScreenState extends State<UsersTableScreen> {
  bool loading = true;
  List<UserWithOrderCount> usersWithOrders = [];

  // Pagination state
  int currentPage = 1;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsersAndOrders();
  }

  Future<void> _fetchUsersAndOrders() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<UserWithOrderCount> tempList = [];

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();

      final ordersSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(userId)
              .collection('orderDetail')
              .get();

      int activeOrdersCount =
          ordersSnapshot.docs
              .where((orderDoc) => orderDoc.data()['status'] != 'cancel')
              .length;

      int totalAmountDone = 0;
      for (var orderDoc in ordersSnapshot.docs) {
        var data = orderDoc.data();
        if (data['status'] == 'done') {
          int amount = 0;
          if (data['totalAmount'] != null) {
            if (data['totalAmount'] is int) {
              amount = data['totalAmount'] as int;
            } else if (data['totalAmount'] is double) {
              amount = (data['totalAmount'] as double).toInt();
            }
          }
          totalAmountDone += amount;
        }
      }

      // Parse createdAt Timestamp if present
      DateTime? createdAt;
      if (userData['createdAt'] != null && userData['createdAt'] is Timestamp) {
        createdAt = (userData['createdAt'] as Timestamp).toDate();
      }

      tempList.add(
        UserWithOrderCount(
          userId: userId,
          email: userData['email'] ?? '',
          name: userData['name'] ?? '',
          totalOrders: activeOrdersCount,
          isActive: userData['isActive'] ?? true,
          totalAmount: totalAmountDone,
          createdAt: createdAt,
          address: userData['address'] ?? '',
        ),
      );
    }

    setState(() {
      usersWithOrders = tempList;
      loading = false;
      currentPage = 1;
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }

  Future<void> _toggleUserActiveStatus(String userId, bool newStatus) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isActive': newStatus,
    });
    setState(() {
      usersWithOrders =
          usersWithOrders.map((user) {
            if (user.userId == userId) {
              return user.copyWith(isActive: newStatus);
            }
            return user;
          }).toList();
    });
  }

  // Get current page users subset
  List<UserWithOrderCount> get paginatedUsers {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (startIndex + rowsPerPage) > usersWithOrders.length
            ? usersWithOrders.length
            : (startIndex + rowsPerPage);
    return usersWithOrders.sublist(startIndex, endIndex);
  }

  // Total pages count
  int get totalPages => (usersWithOrders.length / rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Users")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;

    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isLargeScreen ? screenWidth * 0.7 : 600,
                  maxWidth: isLargeScreen ? screenWidth * 0.8 : 600,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF1E1E2C),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'User Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Total Orders')),
                          DataColumn(label: Text('Total Amount')),
                          DataColumn(label: Text('Created At')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('Active')),
                        ],
                        rows:
                            paginatedUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user.email)),
                                  DataCell(Text(user.name)),
                                  DataCell(Text(user.totalOrders.toString())),
                                  DataCell(
                                    Text(
                                      '\$${user.totalAmount.toStringAsFixed(0)}',
                                    ),
                                  ),
                                  DataCell(Text(formatDate(user.createdAt))),
                                  DataCell(
                                    SizedBox(
                                      width:
                                          200, // fixed width for address column
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(user.address),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Switch(
                                      value: user.isActive,
                                      onChanged:
                                          (value) => _toggleUserActiveStatus(
                                            user.userId,
                                            value,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed:
                      currentPage > 1
                          ? () => setState(() => currentPage--)
                          : null,
                ),

                // Page number buttons
                for (int i = 1; i <= totalPages; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            i == currentPage ? Colors.blue : Colors.grey[700],
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => setState(() => currentPage = i),
                      child: Text('$i', style: const TextStyle(fontSize: 14)),
                    ),
                  ),

                // Next button
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed:
                      currentPage < totalPages
                          ? () => setState(() => currentPage++)
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserWithOrderCount {
  final String userId;
  final String email;
  final String name;
  final int totalOrders;
  final bool isActive;
  final int totalAmount;
  final DateTime? createdAt; // nullable in case missing
  final String address;

  UserWithOrderCount({
    required this.userId,
    required this.email,
    required this.name,
    required this.totalOrders,
    required this.isActive,
    required this.totalAmount,
    this.createdAt,
    this.address = '',
  });

  UserWithOrderCount copyWith({bool? isActive}) {
    return UserWithOrderCount(
      userId: userId,
      email: email,
      name: name,
      totalOrders: totalOrders,
      isActive: isActive ?? this.isActive,
      totalAmount: totalAmount,
      createdAt: createdAt,
      address: address,
    );
  }
}
