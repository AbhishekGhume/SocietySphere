// lib/screens/admin/users/manage_admins_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  Future<void> _updateAdminStatus(String uid, bool isAdmin) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      if (isAdmin) {
        // Add 'admin' to the roles array
        await userRef.update({
          'roles': FieldValue.arrayUnion(['admin'])
        });
      } else {
        // Remove 'admin' from the roles array
        await userRef.update({
          'roles': FieldValue.arrayRemove(['admin'])
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin status updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
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
        title: const Text('Manage Admins'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Query for all active users who are residents
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isActive', isEqualTo: true)
            .where('roles', arrayContains: 'resident')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load residents.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No residents found.'));
          }

          final residents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: residents.length,
            itemBuilder: (context, index) {
              final user = residents[index];
              final data = user.data();
              final List<dynamic> roles = data['roles'] ?? [];
              final bool isAdmin = roles.contains('admin');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(data['firstName']?[0] ?? 'U'),
                  ),
                  title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
                  subtitle: Text(data['email'] ?? 'No email'),
                  trailing: Switch(
                    value: isAdmin,
                    onChanged: (value) {
                      _updateAdminStatus(user.id, value);
                    },
                    activeColor: Colors.blue.shade600,
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
