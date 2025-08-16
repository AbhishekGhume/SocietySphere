// lib/screens/resident/payments/pending_payments_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/resident/payments/make_payment_screen.dart';

class PendingPaymentsScreen extends StatelessWidget {
  const PendingPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Pending Payments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: uid == null
          ? const Center(child: Text('Please log in to view payments.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('userId', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .orderBy('dueDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load payments.'));
          }
          final pendingDocs = snapshot.data?.docs ?? [];
          if (pendingDocs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text('No pending payments!', style: TextStyle(fontSize: 18, color: Colors.black87)),
                  Text('You are all caught up.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pendingDocs.length,
            itemBuilder: (context, index) {
              final doc = pendingDocs[index];
              return _PaymentCard(
                title: (doc['title'] ?? 'Payment').toString(),
                amount: (doc['amount'] ?? 0),
                dueDateLabel: _formatDue(doc['dueDate']),
                isOverdue: _isOverdue(doc['dueDate']),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // UPDATED: Navigate to the new Make Payment screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MakePaymentScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Proceed to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  static String _formatDue(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return 'Due: ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return 'Due: —';
  }

  static bool _isOverdue(dynamic ts) {
    if (ts is Timestamp) {
      final dueDate = ts.toDate();
      final today = DateTime.now();
      return dueDate.isBefore(DateTime(today.year, today.month, today.day));
    }
    return false;
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final num amount;
  final String dueDateLabel;
  final bool isOverdue;

  const _PaymentCard({
    required this.title,
    required this.amount,
    required this.dueDateLabel,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isOverdue ? Colors.red.shade200 : Colors.grey.shade300),
      ),
      color: isOverdue ? Colors.red.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                Text(
                  '₹ ${_formatAmount(amount)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isOverdue ? Colors.red.shade700 : const Color(0xFF1A1A1A)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dueDateLabel,
                  style: TextStyle(fontSize: 12, color: isOverdue ? Colors.red.shade700 : const Color(0xFF6B7280), fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(12)),
                    child: const Text('OVERDUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(num amount) {
    if (amount is int) return amount.toString();
    return (amount as double).toStringAsFixed(0);
  }
}
