import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Generic count for top-level collections like users, services, reviews, contactRequests
  static Future<int> getCount(String collectionName) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection(collectionName)
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  // Count all orderDetail docs with status == 'pending' across all users (collection group query)
  static Future<int> getPendingOrdersCount() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collectionGroup('orderDetail')
            .where('status', isEqualTo: 'pending')
            .get();
    return snapshot.size;
  }

  // Fetch all counts needed for dashboard
  static Future<Map<String, int>> fetchDashboardCounts() async {
    final usersCount = await getCount('users');
    final pendingOrdersCount = await getPendingOrdersCount();
    final servicesCount = await getCount('services');
    final reviewsCount = await getCount('reviews');
    final contactRequestsCount = await getCount('contactRequests');

    return {
      'users': usersCount,
      'orders': pendingOrdersCount,
      'services': servicesCount,
      'reviews': reviewsCount,
      'contactRequests': contactRequestsCount,
    };
  }

 static Future<Map<DateTime, int>> fetchOrderCountsAllUsers() async {
    // Get all user IDs from orders collection
    QuerySnapshot userDocs =
        await FirebaseFirestore.instance.collection('orders').get();

    Map<DateTime, int> countsByDate = {};

    for (var userDoc in userDocs.docs) {
      String userId = userDoc.id;

      QuerySnapshot orderDetails =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(userId)
              .collection('orderDetail')
              .get();

      for (var orderDoc in orderDetails.docs) {
        Timestamp ts = orderDoc['createdAt'] as Timestamp;
        DateTime date = ts.toDate();

        DateTime dateOnly = DateTime(date.year, date.month, date.day);

        countsByDate[dateOnly] = (countsByDate[dateOnly] ?? 0) + 1;
      }
    }

    return countsByDate;
  }
}
