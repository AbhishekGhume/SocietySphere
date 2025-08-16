// lib/screens/admin_complaint_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;
  const AdminComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<AdminComplaintDetailsScreen> createState() => _AdminComplaintDetailsScreenState();
}

class _AdminComplaintDetailsScreenState extends State<AdminComplaintDetailsScreen> {
  final _responseController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['Pending', 'In Progress', 'Resolved'];

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _submitResponse() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('complaints').doc(widget.complaintId).update({
        'status': _selectedStatus,
        'adminResponse': _responseController.text.trim().isEmpty ? null : _responseController.text.trim(),
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit response: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').doc(widget.complaintId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Complaint not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Use a local variable for status to avoid issues with widget rebuilds
          final currentStatus = data['status'];
          _selectedStatus ??= currentStatus;

          // Set controller text only if it's not already set to avoid overwriting admin input
          if (_responseController.text.isEmpty) {
            _responseController.text = data['adminResponse'] ?? '';
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildComplaintInfoCard(data),
                const SizedBox(height: 16),
                _buildAdminResponseCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintInfoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    data['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: data['status'] ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'By ${data['userName'] ?? 'N/A'} (Flat ${data['flat'] ?? 'N/A'}) • ${_formatDate(data['createdAt'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const Divider(height: 24),
            Text(
              data['description'] ?? 'No description.',
              style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
            ),
            if (data['imageUrl'] != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(data['imageUrl'],
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Text('Could not load image.'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminResponseCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Response', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              style: const TextStyle(color: Colors.black87), // FIX: Style for selected item
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Response Message', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              maxLines: 4,
              style: const TextStyle(color: Colors.black87), // FIX: Style for typed text
              decoration: InputDecoration(
                hintText: 'Provide updates or response to the resident...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitResponse,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.send_outlined, size: 18),
                label: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Response'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
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

// Re-using the status chip from the list screen
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
