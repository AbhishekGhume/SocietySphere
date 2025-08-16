// lib/screens/admin/maintenance/maintenance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:society_manager/screens/admin/maintenance/set_maintenance_screen.dart';

class MaintenanceHistoryScreen extends StatelessWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Maintenance History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('maintenance_settings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load history.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No maintenance history found.'),
                ],
              ),
            );
          }

          final historyDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyDocs.length,
            itemBuilder: (context, index) {
              final doc = historyDocs[index];
              return _HistoryCard(doc: doc);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _HistoryCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final category = data['category'] ?? 'Maintenance';
    final amount = (data['amount'] ?? 0) as num;
    final dueDate = _formatDate(data['dueDate']);
    final isActive = data['active'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text('$category - ₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text('Due on: $dueDate', style: TextStyle(color: Colors.grey[700])),
        trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade200,
          child: Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ),
        onTap: () {
          // Navigate to SetMaintenanceScreen in Edit Mode
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetMaintenanceScreen(maintenanceId: doc.id),
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
