// lib/screens/admin/payments/admin_payment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPaymentDetailsScreen extends StatelessWidget {
  final String paymentId;
  const AdminPaymentDetailsScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('payments').doc(paymentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Payment record not found.'));
          }

          final data = snapshot.data!.data()!;
          final amount = (data['amount'] ?? 0) as num;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Payment',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Status: Paid',
                              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '₹ ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Resident Details
                    const Text('Paid By', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      data['userName'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Text(
                      'Flat: ${data['flat'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Transaction Details
                    const Text('Transaction Details', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    _buildDetailRow('Paid On:', _formatDate(data['paidAt'])),
                    _buildDetailRow('Due Date:', _formatDate(data['dueDate'])),
                    _buildDetailRow('Payment Method:', data['paymentMethod'] ?? 'N/A'),
                    _buildDetailRow('Transaction ID:', data['transactionId'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd-MM-yyyy, hh:mm a').format(timestamp.toDate());
    }
    return 'N/A';
  }
}
