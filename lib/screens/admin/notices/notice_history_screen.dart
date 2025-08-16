// lib/screens/admin/notices/notice_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:society_manager/screens/admin/notices/post_notice_screen.dart';

class NoticeHistoryScreen extends StatelessWidget {
  const NoticeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Notices'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load notices.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notices found.'));
          }

          final noticeDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: noticeDocs.length,
            itemBuilder: (context, index) {
              final doc = noticeDocs[index];
              return _NoticeCard(doc: doc);
            },
          );
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _NoticeCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final title = data['title'] ?? 'No Title';
    final date = _formatDate(data['createdAt']);
    final priority = data['priority'] ?? 'low';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text('Posted on: $date', style: TextStyle(color: Colors.grey[700])),
        trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
        leading: _PriorityIcon(priority: priority),
        onTap: () {
          // Navigate to PostNoticeScreen in Edit Mode
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostNoticeScreen(noticeId: doc.id),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
    }
    return 'N/A';
  }
}

class _PriorityIcon extends StatelessWidget {
  final String priority;
  const _PriorityIcon({required this.priority});
  
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'high':
        color = Colors.red.shade400;
        break;
      case 'medium':
        color = Colors.orange.shade400;
        break;
      default:
        color = Colors.blue.shade400;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.15),
      child: Icon(Icons.flag_outlined, color: color),
    );
  }
}

