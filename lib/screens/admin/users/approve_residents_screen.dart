// lib/screens/admin/users/approve_residents_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveResidentsScreen extends StatefulWidget {
  const ApproveResidentsScreen({super.key});

  @override
  State<ApproveResidentsScreen> createState() => _ApproveResidentsScreenState();
}

class _ApproveResidentsScreenState extends State<ApproveResidentsScreen> {
  Future<void> _approveUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isActive': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resident approved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve resident: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Approve Residents'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // This is the key query: fetch users who are NOT active.
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isActive', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load users.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_disabled_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending approvals.', style: TextStyle(color: Colors.black87),),
                ],
              ),
            );
          }

          final pendingUsers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final user = pendingUsers[index];
              final data = user.data();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(data['firstName']?[0] ?? 'U'),
                  ),
                  title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
                  subtitle: Text(data['email'] ?? 'No email'),
                  trailing: ElevatedButton(
                    onPressed: () => _approveUser(user.id),
                    child: const Text('Approve'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
