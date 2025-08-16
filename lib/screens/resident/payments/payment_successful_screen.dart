// lib/screens/resident/payments/payment_successful_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class PaymentSuccessfulScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const PaymentSuccessfulScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final amount = (paymentData['amount'] ?? 0.0) as num;
    final processingFee = 100.0; // Example fee
    final total = amount + processingFee;
    final transactionId = paymentData['transactionId'] ?? 'N/A';
    final paymentType = paymentData['title'] ?? 'Maintenance';
    final paymentMethod = paymentData['paymentMethod'] ?? 'Razorpay';
    final now = DateTime.now();
    final formattedDate = DateFormat('d/M/y').format(now);
    final formattedTime = DateFormat('hh:mm:ss a').format(now);


    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        // FIX: Wrapped the content in a SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FIX: Replaced Spacer with SizedBox for predictable spacing
                const SizedBox(height: 40),
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your payment has been processed successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 32),
                _buildConfirmationCard(
                  transactionId: transactionId,
                  paymentType: paymentType,
                  amount: amount,
                  processingFee: processingFee,
                  total: total,
                  date: formattedDate,
                  time: formattedTime,
                  paymentMethod: paymentMethod,
                ),
                const SizedBox(height: 40), // FIX: Replaced Spacer with SizedBox
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A receipt has been sent to your registered email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationCard({
    required String transactionId,
    required String paymentType,
    required num amount,
    required double processingFee,
    required double total,
    required String date,
    required String time,
    required String paymentMethod,
  }) {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Payment Confirmation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Transaction completed successfully', style: TextStyle(color: Colors.green.shade800)),
            const Divider(height: 24),
            _infoRow('Transaction ID', transactionId),
            _infoRow('Payment Type', paymentType),
            _infoRow('Amount', '₹ ${amount.toStringAsFixed(2)}'),
            _infoRow('Processing Fee', '₹ ${processingFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _infoRow('Total Paid', '₹ ${total.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 16),
            _infoRowWithIcon(Icons.calendar_today_outlined, 'Date & Time', '$date\n$time'),
            _infoRowWithIcon(Icons.credit_card, 'Payment Method', paymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 18 : 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithIcon(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
