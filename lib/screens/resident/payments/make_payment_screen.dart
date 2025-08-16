// lib/screens/resident/payments/make_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:society_manager/screens/resident/payments/payment_successful_screen.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  String? _selectedPaymentId;
  Map<String, dynamic>? _selectedPaymentData;

  Future<void> _processPayment() async {
    if (_selectedPaymentId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    try {
      await FirebaseFirestore.instance.collection('payments').doc(_selectedPaymentId).update({
        'status': 'paid',
        'paidAt': Timestamp.now(),
        'paymentMethod': 'Razorpay',
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      });

      Navigator.pop(context); // Close loading dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessfulScreen(
            paymentData: _selectedPaymentData!,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Make Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              title: 'Select Payment',
              subtitle: 'Choose which payment you want to make',
              child: uid == null
                  ? const Text('Please log in.')
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('userId', isEqualTo: uid)
                    .where('status', isEqualTo: 'pending')
                    .orderBy('dueDate')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No pending payments.', style: TextStyle(color: Colors.black87)));
                  }
                  final payments = snapshot.data!.docs;
                  return Column(
                    children: payments.map((doc) {
                      return _PaymentOptionCard(
                        doc: doc,
                        isSelected: _selectedPaymentId == doc.id,
                        onSelect: () {
                          setState(() {
                            _selectedPaymentId = doc.id;
                            _selectedPaymentData = doc.data();
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedPaymentId != null)
              _buildSection(
                title: 'Payment Summary',
                child: _PaymentSummary(paymentData: _selectedPaymentData!),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _selectedPaymentId == null
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _processPayment,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Pay Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, String? subtitle, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX: Added explicit color to title
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              // FIX: Added explicit color to subtitle
              Text(subtitle, style: TextStyle(color: Colors.grey[700])),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentOptionCard({required this.doc, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final isOverdue = _isOverdue(data['dueDate']);

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: doc.id,
              groupValue: isSelected ? doc.id : null,
              onChanged: (value) => onSelect(),
              activeColor: Colors.blue.shade600,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIX: Added explicit color to payment title
                  Text(data['title'] ?? 'Payment', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(data['description'] ?? 'Monthly Charges', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Due: ${_formatDate(data['dueDate'])}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FIX: Added explicit color to amount
                Text('₹ ${data['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                _StatusChip(isOverdue: isOverdue),
              ],
            )
          ],
        ),
      ),
    );
  }

  static bool _isOverdue(dynamic ts) {
    if (ts is Timestamp) {
      final dueDate = ts.toDate();
      final today = DateTime.now();
      return dueDate.isBefore(DateTime(today.year, today.month, today.day));
    }
    return false;
  }

  static String _formatDate(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return '—';
  }
}

class _StatusChip extends StatelessWidget {
  final bool isOverdue;
  const _StatusChip({required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.error_outline : Icons.calendar_today_outlined,
            size: 12,
            color: isOverdue ? Colors.red.shade700 : Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            isOverdue ? 'Overdue' : 'Due',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isOverdue ? Colors.red.shade700 : Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  const _PaymentSummary({required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final amount = (paymentData['amount'] ?? 0.0) as num;
    final processingFee = 100.0; // Example fee
    final total = amount + processingFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: Added explicit color to summary title
        Text(paymentData['title'] ?? 'Payment', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(paymentData['description'] ?? 'Monthly Charges', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const Divider(height: 24),
        _summaryRow('Amount', '₹ ${amount.toStringAsFixed(2)}'),
        _summaryRow('Processing Fee', '₹ ${processingFee.toStringAsFixed(2)}'),
        const Divider(height: 24),
        _summaryRow('Total', '₹ ${total.toStringAsFixed(2)}', isTotal: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: Colors.grey[700])),
          // FIX: Added explicit color to summary value
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
