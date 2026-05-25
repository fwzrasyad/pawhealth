import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../main.dart'; // To access navigatorKey

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await _apiService.get('/notifications', token: token);
      
      // Handle the nested data structure depending on how Laravel returns it
      final data = response is Map<String, dynamic> && response.containsKey('data') 
          ? response['data'] 
          : response;

      if (mounted) {
        setState(() {
          _notifications = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int index, String id) async {
    setState(() {
      _notifications[index]['read_at'] = DateTime.now().toIso8601String();
    });
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      await _apiService.patch('/notifications/$id/read', {}, token);
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  void _handleTap(int index, Map<String, dynamic> notification) {
    if (notification['read_at'] == null) {
      _markAsRead(index, notification['id'].toString());
    }

    final data = notification['data'] ?? {};
    if (data['appointment_id'] != null) {
      navigatorKey.currentState?.pushNamed(
        '/appointment-details',
        arguments: {'id': data['appointment_id'].toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: const Text(
          'Notifications', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Figtree')
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final bool isUnread = notification['read_at'] == null;
                    final data = notification['data'] ?? {};

                    return GestureDetector(
                      onTap: () => _handleTap(index, notification),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUnread ? const Color(0xFFF3EFFF) : Colors.white, // Light blue/purple for unread
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUnread ? const Color(0xFFC4B5FD) : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Notification',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                fontFamily: 'Figtree',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['message'] ?? 'You have a new update regarding your pet.',
                              style: TextStyle(
                                color: Colors.grey.shade700, 
                                fontSize: 13,
                                fontFamily: 'Figtree',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_off, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A0F2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have no new notifications right now.',
            style: TextStyle(
              fontFamily: 'Figtree',
              color: Color(0xFF9B8CB8),
            ),
          ),
        ],
      ),
    );
  }
}
