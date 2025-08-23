// lib/screens/resident/complaints/complaint_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/resident/complaints/new_complaint_screen.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  Future<void> _deleteComplaint(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion',
          style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),),
        content: const Text('Are you sure you want to delete this complaint?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).delete();
      Navigator.pop(context); // Go back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint deleted successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete complaint: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Delete button - always visible
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteComplaint(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').doc(complaintId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Complaint not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'Pending';
          final bool hasAdminResponse = data['adminResponse'] != null;
          final bool canEdit = status == 'Pending' && !hasAdminResponse;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'No Title',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          StatusChip(status: status),
                        ],
                      ),
                      const Divider(height: 24),

                      // Category and Priority
                      if (data['category'] != null) ...[
                        Row(
                          children: [
                            Icon(Icons.category_outlined, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Category: ${data['category']}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (data['priority'] != null) ...[
                        Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 16, color: _getPriorityColor(data['priority'])),
                            const SizedBox(width: 8),
                            Text(
                              'Priority: ${data['priority']}',
                              style: TextStyle(fontSize: 14, color: _getPriorityColor(data['priority']), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      Text(
                        data['description'] ?? 'No description provided.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                      ),
                      if (data['imageUrl'] != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(data['imageUrl'])),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${_formatDate(data['createdAt'])}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.update, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Last Updated: ${_formatDate(data['updatedAt'])}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Admin Response Section
              if (hasAdminResponse)
                Card(
                  margin: const EdgeInsets.only(top: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              "Admin's Response",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          data['adminResponse'],
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

              // Edit Button (only for pending complaints without admin response)
              if (canEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewComplaintScreen(complaintId: complaintId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Complaint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Info message for non-editable complaints
              if (!canEdit && !hasAdminResponse)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This complaint is currently being processed and cannot be edited.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade700;
      case 'Medium':
        return Colors.orange.shade700;
      case 'Low':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
    return 'N/A';
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case 'In Progress':
        color = Colors.orange.shade700;
        icon = Icons.hourglass_bottom;
        break;
      case 'Resolved':
        color = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      default: // Pending
        color = Colors.red.shade700;
        icon = Icons.pending_actions;
        break;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(status),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      side: BorderSide.none,
    );
  }
}