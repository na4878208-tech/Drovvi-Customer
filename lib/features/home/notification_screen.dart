import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/jwt.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import '../../common_widgets/custom_button.dart';
import '../../constants/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jwt_decode/jwt_decode.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool hasNotifications = false;

  @override
  void initState() {
    super.initState();

    // ✅ Temporary: Pehle token debug karo
    _debugTokenInfo().then((_) {
      _loadNotifications();
    });
  }

  Future<void> _debugTokenInfo() async {
    print('=== TOKEN DEBUG INFO ===');
    final token = await LocalStorage.getToken();
    print('Token exists: ${token != null}');

    if (token != null) {
      print('Token length: ${token.length}');
      print(
        'Token first 50 chars: ${token.substring(0, min(50, token.length))}...',
      );

      // Try to parse JWT
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        print('✅ JWT parsed successfully');
        print('Payload keys: ${payload.keys}');

        // Check for common user ID keys
        final possibleKeys = [
          'id',
          'userId',
          'user_id',
          '_id',
          'sub',
          'user.id',
          'user._id',
        ];
        for (var key in possibleKeys) {
          if (payload[key] != null) {
            print('   Found "$key": ${payload[key]}');
          }
        }

        // If no key found, print full payload
        bool found = false;
        for (var key in payload.keys) {
          if (key.toString().toLowerCase().contains('id') ||
              key.toString().toLowerCase().contains('user')) {
            print('   🔑 "$key": ${payload[key]}');
            found = true;
          }
        }

        if (!found) {
          print('   Full payload: $payload');
        }
      } catch (e) {
        print('❌ JWT parse error: $e');
      }
    }
    print('=== END DEBUG INFO ===');
  }

  Future<void> _loadNotifications() async {
    try {
      print('=== 🔔 LOADING NOTIFICATIONS ===');

      // 1. Get token
      final token = await LocalStorage.getToken();
      if (token == null) {
        print('❌ No token in LocalStorage');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('📱 Token found (length: ${token.length})');

      // 2. Parse token and extract userId
      String? userId;

      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        print('✅ JWT parsed successfully');

        // DEBUG: Print first few key-value pairs
        print('🔍 JWT Structure:');
        int count = 0;
        payload.forEach((key, value) {
          if (count < 10) {
            // Limit output
            print('   $key: $value');
            count++;
          }
        });

        // ✅ SIMPLE FIX: Just print and manually check
        print('\n🎯 MANUAL CHECK NEEDED:');
        print('1. Look for any ID field in above output');
        print('2. Common fields: id, userId, user_id, _id, sub, uid');
        print('3. If you see something like "id": "123", use that');

        // Try to auto-detect
        final possibleKeys = ['id', 'userId', 'user_id', '_id', 'sub', 'uid'];
        for (var key in possibleKeys) {
          if (payload.containsKey(key)) {
            userId = payload[key]?.toString();
            print('✅ Auto-detected: $key = $userId');
            break;
          }
        }
      } catch (e) {
        print('❌ JWT parse failed: $e');
      }

      // 3. If still no userId, use manual/hardcoded
      if (userId == null || userId.isEmpty) {
        print('⚠️ Could not extract userId from token');
        userId =
            "PASTE_YOUR_FIREBASE_USER_ID_HERE"; // Example: "uid123", "user_abc"

        print('⚠️ Using hardcoded userId: $userId');
        print('   (This is for testing only - fix JWT parsing later)');
      }

      print('🎯 Final userId for query: $userId');

      // 4. Now query Firestore
      setState(() {
        isLoading = true;
      });

      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      print(
        '📡 Firestore query completed: ${snapshot.docs.length} notifications found',
      );

      if (snapshot.docs.isNotEmpty) {
        // Process notifications...
        notifications = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] ?? 'New Notification',
            'subtitle': data['body'] ?? '',
            'time': _formatTime(data['createdAt']),
            'type': data['type'] ?? 'general',
            'read': data['read'] ?? false,
            'data': data['data'] ?? {},
          };
        }).toList();

        hasNotifications = true;
        print('✅ ${notifications.length} notifications loaded');
      } else {
        print('ℹ️ No notifications in Firestore, checking orders...');
        await _loadFromOrdersHistory(userId);
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('❌ Error loading notifications: $error');
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _loadFromOrdersHistory(String userId) async {
    try {
      // User ke orders se notification-like data banaye
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (ordersSnapshot.docs.isNotEmpty) {
        notifications = [];

        for (var doc in ordersSnapshot.docs) {
          final orderData = doc.data();

          // Order creation notification
          notifications.add({
            'id': doc.id + '_created',
            'title':
                '🎉 Order #${orderData['orderNumber'] ?? doc.id.substring(0, 8)}',
            'subtitle': 'Order created successfully',
            'time': _formatTime(orderData['createdAt']),
            'type': 'order_created',
            'read': false,
            'data': {'orderId': doc.id, 'type': 'order'},
          });

          // Status updates notifications
          if (orderData.containsKey('statusUpdates')) {
            final List<dynamic> updates = orderData['statusUpdates'] ?? [];
            for (var update in updates) {
              if (update is Map) {
                notifications.add({
                  'id': doc.id + '_${update['status']}',
                  'title': _getStatusTitle(update['status']),
                  'subtitle': 'Order status updated',
                  'time': _formatTime(update['timestamp']),
                  'type': 'status_update',
                  'read': false,
                  'data': {'orderId': doc.id, 'status': update['status']},
                });
              }
            }
          }
        }

        if (notifications.isNotEmpty) {
          // Sort by time (latest first)
          notifications.sort((a, b) => b['time'].compareTo(a['time']));
          hasNotifications = true;
        }
      }
    } catch (error) {
      print('Error loading from orders: $error');
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'created':
        return '📦 Order Created';
      case 'assigned':
        return '🚚 Driver Assigned';
      case 'picked_up':
        return '📦 Order Picked Up';
      case 'in_transit':
        return '🚚 Order in Transit';
      case 'delivered':
        return '🎉 Order Delivered';
      case 'cancelled':
        return '❌ Order Cancelled';
      default:
        return '📦 Order Update';
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      DateTime time;

      if (timestamp is Timestamp) {
        time = timestamp.toDate();
      } else if (timestamp is String) {
        time = DateTime.parse(timestamp);
      } else {
        return 'Just now';
      }

      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day ago';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _markAllAsRead() async {
    // ✅ Get userId from JWT token
    final token = await LocalStorage.getToken();
    if (token == null) return;

    final userId = getUserIdFromToken(token);
    if (userId == null) return;

    final batch = _firestore.batch();

    for (var notification in notifications) {
      if (!notification['read']) {
        final docRef = _firestore
            .collection('notifications')
            .doc(notification['id']);
        batch.update(docRef, {'read': true});
      }
    }

    try {
      await batch.commit();
      setState(() {
        for (var notification in notifications) {
          notification['read'] = true;
        }
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('All notifications marked as read')),
      // );

      AppSnackBar.showSuccess(context, "All notifications marked as read");
    } catch (error) {
      print('Error marking as read: $error');
    }
  }

  Future<void> _clearAllNotifications() async {
    // ✅ Get userId from JWT token
    final token = await LocalStorage.getToken();
    if (token == null) return;

    final userId = getUserIdFromToken(token);
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final query = await _firestore
                    .collection('notifications')
                    .where('userId', isEqualTo: userId) // ✅ Use userId
                    .get();

                final batch = _firestore.batch();
                for (var doc in query.docs) {
                  batch.delete(doc.reference);
                }

                await batch.commit();

                setState(() {
                  notifications.clear();
                  hasNotifications = false;
                });

                AppSnackBar.showSuccess(context, "All notifications cleared");
              } catch (error) {
                print('Error clearing notifications: $error');
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    final data = notification['data'];
    final type = notification['type'];

    print('Notification tapped: $type, Data: $data');

    // Navigate based on notification type
    if (type == 'order_created' || type == 'status_update') {
      final orderId = data['orderId'];
      if (orderId != null) {
        // Navigate to order details
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => OrderDetailsScreen(orderId: orderId),
        // ));
      }
    }

    // Mark as read
    if (!notification['read']) {
      _markAsRead(notification['id']);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        final index = notifications.indexWhere(
          (n) => n['id'] == notificationId,
        );
        if (index != -1) {
          notifications[index]['read'] = true;
        }
      });
    } catch (error) {
      print('Error marking as read: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color blueColor = AppColors.electricTeal;

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        backgroundColor: blueColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.pureWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.pureWhite,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: isLoading
          ? _loadingUI()
          : hasNotifications
          ? _notificationListUI()
          : _emptyStateUI(),
    );
  }

  Widget _loadingUI() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricTeal),
      ),
    );
  }

  Widget _emptyStateUI() {
    const Color blueColor = AppColors.electricTeal;
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(child: Image.asset("assets/empty_notification.png", width: 350)),
        const SizedBox(height: 20),
        const Text(
          "No notifications yet",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "When you have notification, you will see\n them here",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.darkText, fontSize: 17),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70),
          child: CustomButton(
            text: "Refresh",
            backgroundColor: blueColor,
            borderColor: blueColor,
            textColor: AppColors.pureWhite,
            onPressed: _loadNotifications,
          ),
        ),
      ],
    );
  }

  Widget _notificationListUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // TOP ACTION ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: notifications.any((n) => !n['read'])
                    ? _markAllAsRead
                    : null,
                child: Text(
                  "Mark all as read",
                  style: TextStyle(
                    color: notifications.any((n) => !n['read'])
                        ? AppColors.darkText
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: notifications.isNotEmpty
                    ? _clearAllNotifications
                    : null,
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: notifications.isNotEmpty
                        ? AppColors.darkText
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          // LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.electricTeal,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final isRead = item['read'] ?? false;

                  return GestureDetector(
                    onTap: () => _onNotificationTap(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isRead
                            ? AppColors.pureWhite
                            : AppColors.electricTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightBorder,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLORED LINE (FULL HEIGHT)
                          Container(
                            height: 76,
                            width: 6,
                            decoration: BoxDecoration(
                              color: _getNotificationColor(item['type']),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              ),
                            ),
                          ),

                          // UNREAD DOT
                          if (!isRead)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 12),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                          // CONTENT
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TITLE + TIME
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item["title"],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        item["time"],
                                        style: TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // SUBTITLE
                                  Text(
                                    item["subtitle"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.darkText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_created':
        return Colors.green;
      case 'status_update':
        return Colors.blue;
      case 'payment_update':
        return Colors.orange;
      default:
        return AppColors.electricTeal;
    }
  }
}