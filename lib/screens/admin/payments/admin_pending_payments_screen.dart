// lib/screens/admin/payments/admin_pending_payments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPendingPaymentsScreen extends StatefulWidget {
  const AdminPendingPaymentsScreen({super.key});

  @override
  State<AdminPendingPaymentsScreen> createState() => _AdminPendingPaymentsScreenState();
}

class _AdminPendingPaymentsScreenState extends State<AdminPendingPaymentsScreen> {
  String _searchQuery = '';
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pending Payments',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('payments')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('dueDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Failed to load payments.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pending payments found.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                // --- Grouping and Filtering Logic ---
                final payments = snapshot.data!.docs;
                Map<String, List<QueryDocumentSnapshot>> groupedByResident = {};

                for (var payment in payments) {
                  final data = payment.data();
                  // Month Filter
                  if (_selectedMonth != null) {
                    final dueDate = (data['dueDate'] as Timestamp).toDate();
                    if (dueDate.month != _selectedMonth!.month || dueDate.year != _selectedMonth!.year) {
                      continue; // Skip if it doesn't match the selected month
                    }
                  }

                  // Search Filter
                  final residentName = (data['userName'] ?? 'Unknown').toLowerCase();
                  if (_searchQuery.isNotEmpty && !residentName.contains(_searchQuery.toLowerCase())) {
                    continue; // Skip if name doesn't match search
                  }

                  final userId = data['userId'];
                  if (groupedByResident.containsKey(userId)) {
                    groupedByResident[userId]!.add(payment);
                  } else {
                    groupedByResident[userId] = [payment];
                  }
                }

                if (groupedByResident.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching pending payments found.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: groupedByResident.entries.map((entry) {
                    return _ResidentPaymentsCard(
                      residentData: entry.value.first.data() as Map<String, dynamic>, // Use first payment for resident info
                      payments: entry.value,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search by resident name...',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedMonth ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedMonth = pickedDate;
                });
              }
            },
          ),
          if (_selectedMonth != null)
            ActionChip(
              avatar: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                DateFormat('MMM yyyy').format(_selectedMonth!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.blue,
              onPressed: () => setState(() => _selectedMonth = null),
            ),
        ],
      ),
    );
  }
}

class _ResidentPaymentsCard extends StatelessWidget {
  final Map<String, dynamic> residentData;
  final List<QueryDocumentSnapshot> payments;

  const _ResidentPaymentsCard({required this.residentData, required this.payments});

  @override
  Widget build(BuildContext context) {
    num totalDue = payments.fold(0, (sum, item) => sum + (item['amount'] ?? 0));
    final userName = residentData['userName'] as String? ?? 'U';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        iconColor: Colors.blue,
        collapsedIconColor: Colors.grey,
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            // FIX: Safely get the first character
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Flat: ${residentData['flat'] ?? 'N/A'}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: Text(
          '₹${totalDue.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        children: payments.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Container(
            color: Colors.grey[50],
            child: ListTile(
              title: Text(
                data['title'] ?? 'Payment',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Due on: ${_formatDate(data['dueDate'])}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                '₹${data['amount']}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
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

