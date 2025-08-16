// // lib/screens/admin/maintenance/set_maintenance_screen.dart

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SetMaintenanceScreen extends StatefulWidget {
//   const SetMaintenanceScreen({super.key, required String maintenanceId});

//   @override
//   State<SetMaintenanceScreen> createState() => _SetMaintenanceScreenState();
// }

// class _SetMaintenanceScreenState extends State<SetMaintenanceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   DateTime? _selectedDate;
//   bool _isLoading = false;

//   String? _selectedCategory;
//   final List<String> _categories = ['Maintenance', 'Security', 'Parking', 'Cleaning', 'Others'];

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate() async {
//     final DateTime now = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
//       firstDate: now,
//       lastDate: DateTime(now.year + 2),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF4285F4),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _saveMaintenanceSettings() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedDate == null) {
//       _showSnackBar('Please select a due date', Colors.orange);
//       return;
//     }
//     if (_selectedCategory == null) {
//       _showSnackBar('Please select a category', Colors.orange);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final firestore = FirebaseFirestore.instance;
//       final currentUser = FirebaseAuth.instance.currentUser;
//       final adminUid = currentUser?.uid ?? '';
//       final batch = firestore.batch();

//       final activeSettingsQuery = await firestore
//           .collection('maintenance_settings')
//           .where('active', isEqualTo: true)
//           .get();

//       for (var doc in activeSettingsQuery.docs) {
//         batch.update(doc.reference, {'active': false});
//       }

//       final settingsRef = firestore.collection('maintenance_settings').doc();
//       final amount = double.parse(_amountController.text.trim());

//       batch.set(settingsRef, {
//         'amount': amount,
//         'dueDate': Timestamp.fromDate(_selectedDate!),
//         'category': _selectedCategory,
//         'description': _descriptionController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'createdBy': adminUid,
//         'active': true,
//       });

//       final residentsQuery = await firestore
//           .collection('users')
//           .where('isActive', isEqualTo: true)
//           .get();

//       for (var userDoc in residentsQuery.docs) {
//         final userData = userDoc.data();
//         final roles = List<String>.from(userData['roles'] ?? []);

//         if (!roles.contains('resident')) continue;

//         final paymentRef = firestore.collection('payments').doc();

//         batch.set(paymentRef, {
//           'userId': userDoc.id,
//           'title': _selectedCategory,
//           'purpose': _selectedCategory,
//           'description': _descriptionController.text.trim(),
//           'amount': amount,
//           'dueDate': Timestamp.fromDate(_selectedDate!),
//           'status': 'pending',
//           'createdAt': FieldValue.serverTimestamp(),
//           'maintenanceId': settingsRef.id,
//           'flat': userData['flat'] ?? '',
//           'userName': '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
//         });
//       }

//       await batch.commit();

//       if (mounted) {
//         _showSnackBar('Maintenance settings saved successfully!', Colors.green);
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Error saving settings: ${e.toString()}', Colors.red);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Set Maintenance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Maintenance Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
//                     const SizedBox(height: 24),

//                     const Text('Maintenance Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
//                       decoration: InputDecoration(
//                         prefixText: '₹ ',
//                         prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
//                         hintText: '5000',
//                         hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                         filled: true,
//                         fillColor: const Color(0xFFF9FAFB),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) return 'Please enter maintenance amount';
//                         final amount = double.tryParse(value.trim());
//                         if (amount == null || amount <= 0) return 'Please enter a valid amount';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     const Text('Due Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: _selectDate,
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                         decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280), size: 20),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 _selectedDate == null ? 'Select due date' : _formatDate(_selectedDate!),
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _selectedDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A1A)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
//                     const SizedBox(height: 8),
//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,
//                       decoration: InputDecoration(
//                         hintText: 'Select a category',
//                         hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                         filled: true,
//                         fillColor: const Color(0xFFF9FAFB),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       ),
//                       items: _categories.map((String category) {
//                         return DropdownMenuItem<String>(
//                           value: category,
//                           // FIX: Added a style to make the dropdown item text visible
//                           child: Text(category, style: const TextStyle(color: Colors.black87)),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           _selectedCategory = newValue;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Please select a category' : null,
//                     ),
//                     const SizedBox(height: 20),

//                     const Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _descriptionController,
//                       maxLines: 3,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1A1A)),
//                       decoration: InputDecoration(
//                         hintText: 'e.g., Monthly fee for water tank cleaning',
//                         hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                         filled: true,
//                         fillColor: const Color(0xFFF9FAFB),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2)),
//                         contentPadding: const EdgeInsets.all(16),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton.icon(
//                         onPressed: _isLoading ? null : _saveMaintenanceSettings,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF4285F4),
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           disabledBackgroundColor: Colors.grey[300],
//                         ),
//                         icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.save_outlined, color: Colors.white),
//                         label: Text(_isLoading ? 'Saving Settings...' : 'Save Settings', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/screens/admin/maintenance/set_maintenance_screen.dart

import 'package:flutter/material.dart';
// import 'package.cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SetMaintenanceScreen extends StatefulWidget {
  final String? maintenanceId; // Optional ID for editing

  const SetMaintenanceScreen({super.key, this.maintenanceId});

  @override
  State<SetMaintenanceScreen> createState() => _SetMaintenanceScreenState();
}

class _SetMaintenanceScreenState extends State<SetMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  String? _selectedCategory;
  final List<String> _categories = ['Maintenance', 'Security', 'Parking', 'Cleaning', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.maintenanceId != null && widget.maintenanceId!.isNotEmpty) {
      _isEditMode = true;
      _loadMaintenanceData();
    }
  }
  
  Future<void> _loadMaintenanceData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('maintenance_settings')
          .doc(widget.maintenanceId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _amountController.text = (data['amount'] ?? 0).toString();
        _descriptionController.text = data['description'] ?? '';
        _selectedCategory = data['category'];
        if (data['dueDate'] is Timestamp) {
          _selectedDate = (data['dueDate'] as Timestamp).toDate();
        }
        setState(() {});
      }
    } catch (e) {
      _showSnackBar('Failed to load maintenance data: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: _isEditMode ? DateTime(2000) : now, // Allow past dates in edit mode
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMaintenanceSettings() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedCategory == null) {
      _showSnackBar('Please fill all required fields.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final amount = double.parse(_amountController.text.trim());
      
      final maintenanceData = {
        'amount': amount,
        'dueDate': Timestamp.fromDate(_selectedDate!),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditMode) {
        // --- UPDATE LOGIC ---
        final batch = firestore.batch();
        final maintenanceRef = firestore.collection('maintenance_settings').doc(widget.maintenanceId);
        batch.update(maintenanceRef, maintenanceData);

        // Find and update all associated pending payments
        final paymentsQuery = await firestore.collection('payments')
            .where('maintenanceId', isEqualTo: widget.maintenanceId)
            .where('status', isEqualTo: 'pending')
            .get();
      
        for (var doc in paymentsQuery.docs) {
          batch.update(doc.reference, {
            'title': _selectedCategory,
            'description': _descriptionController.text.trim(),
            'amount': amount,
            'dueDate': Timestamp.fromDate(_selectedDate!),
          });
        }
        await batch.commit();
        _showSnackBar('Maintenance updated successfully!', Colors.green);

      } else {
        // --- CREATE LOGIC ---
        final currentUser = FirebaseAuth.instance.currentUser;
        final adminUid = currentUser?.uid ?? '';
        final batch = firestore.batch();

        final settingsRef = firestore.collection('maintenance_settings').doc();
        batch.set(settingsRef, {
          ...maintenanceData,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': adminUid,
          'active': true, 
        });

        final residentsQuery = await firestore.collection('users').where('isActive', isEqualTo: true).get();
        for (var userDoc in residentsQuery.docs) {
          final paymentRef = firestore.collection('payments').doc();
          batch.set(paymentRef, {
            'userId': userDoc.id,
            'title': _selectedCategory,
            'description': _descriptionController.text.trim(),
            'amount': amount,
            'dueDate': Timestamp.fromDate(_selectedDate!),
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'maintenanceId': settingsRef.id,
            'userName': '${userDoc.data()['firstName'] ?? ''} ${userDoc.data()['lastName'] ?? ''}'.trim(),
            'flat': userDoc.data()['flat'] ?? '',
          });
        }
        await batch.commit();
        _showSnackBar('Maintenance settings saved successfully!', Colors.green);
      }

      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      _showSnackBar('Error saving settings: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMaintenance() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(
            color: Colors.black87,
          ),),
        content: const Text('Are you sure you want to delete this maintenance setting and all associated pending payments? This action cannot be undone.', style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final maintenanceRef = firestore.collection('maintenance_settings').doc(widget.maintenanceId);
      batch.delete(maintenanceRef);

      final paymentsQuery = await firestore.collection('payments')
          .where('maintenanceId', isEqualTo: widget.maintenanceId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      for (var doc in paymentsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _showSnackBar('Maintenance and associated payments deleted.', Colors.green);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      _showSnackBar('Error deleting maintenance: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor));
  }

  String _formatDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Maintenance' : 'Set Maintenance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isLoading ? null : _deleteMaintenance,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isEditMode ? 'Update Settings' : 'Maintenance Settings', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 24),

                    const Text('Maintenance Amount', style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(hintText: 'e.g., 500', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an amount.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Due Date', style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        child: Text(_selectedDate == null ? 'Select a date' : _formatDate(_selectedDate!), style: const TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Category', style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.black87)))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) => value == null ? 'Please select a category.' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Description (Optional)', style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(hintText: 'e.g., Monthly fee for water tank cleaning', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveMaintenanceSettings,
                        icon: Icon(_isEditMode ? Icons.update : Icons.save_outlined),
                        label: Text(_isLoading ? 'Saving...' : (_isEditMode ? 'Update Settings' : 'Save Settings')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
