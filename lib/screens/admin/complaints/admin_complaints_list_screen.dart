// lib/screens/admin_complaints_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/admin/complaints/admin_complaint_details_screen.dart';

class AdminComplaintsListScreen extends StatelessWidget {
  const AdminComplaintsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('View Complaints'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load complaints.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints have been submitted.'));
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return _ComplaintCard(complaint: complaint);
            },
          );
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final QueryDocumentSnapshot complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final data = complaint.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'Pending';
    final title = data['title'] ?? 'No Title';
    final description = data['description'] ?? 'No description.';
    final userName = data['userName'] ?? 'Unknown Resident';
    final flat = data['flat'] ?? 'N/A';
    final date = _formatDate(data['createdAt']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminComplaintDetailsScreen(complaintId: complaint.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 32), // Align with title
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  'By $userName (Flat $flat) • $date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
    return 'N/A';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (status) {
      case 'In Progress':
        bgColor = Colors.amber.shade100;
        fgColor = Colors.amber.shade800;
        icon = Icons.timelapse;
        break;
      case 'Resolved':
        bgColor = Colors.green.shade100;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      default: // Pending
        bgColor = Colors.red.shade100;
        fgColor = Colors.red.shade800;
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: fgColor, size: 16),
      label: Text(status),
      backgroundColor: bgColor,
      labelStyle: TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      side: BorderSide.none,
    );
  }
}
