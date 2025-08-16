// lib/screens/new_complaint_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State for new fields
  String? _selectedCategory;
  String _selectedPriority = 'Medium';
  File? _imageFile;

  bool _isLoading = false;

  final List<String> _categories = [
    'Maintenance', 'Security', 'Noise Complaint', 'Parking', 'Cleanliness', 'Utilities', 'Other'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Image Picking Logic ---
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  // --- Submission Logic ---
  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in.', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? imageUrl;
      // 1. Upload image if one was selected
      if (_imageFile != null) {
        final fileName = path.basename(_imageFile!.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('complaint_images')
            .child('${DateTime.now().toIso8601String()}_$fileName');

        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // 2. Fetch user details
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      // 3. Save complaint to Firestore
      await FirebaseFirestore.instance.collection('complaints').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'status': 'Pending',
        'imageUrl': imageUrl, // Can be null
        'userId': user.uid,
        'userName': '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'.trim(),
        'flat': userData?['flat'] ?? 'N/A',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'adminResponse': null,
      });

      _showSnackBar('Complaint submitted successfully!', Colors.green);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Failed to submit complaint: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create Complaint'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildComplaintForm(),
            const SizedBox(height: 24),
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  // --- UI Builder Widgets ---

  Widget _buildComplaintForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Submit a New Complaint', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Text('Describe your issue in detail so we can help you quickly.', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),

              // Title, Category, Priority Fields
              _buildTextFormField(controller: _titleController, label: 'Complaint Title *', hint: 'Brief description of the issue'),
              const SizedBox(height: 20),
              _buildDropdownField(value: _selectedCategory, items: _categories, label: 'Category *', hint: 'Select complaint category', onChanged: (val) => setState(() => _selectedCategory = val)),
              const SizedBox(height: 20),
              _buildPriorityDropdown(),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _descriptionController, label: 'Detailed Description *', hint: 'Provide details about the issue...', maxLines: 5),
              const SizedBox(height: 20),

              // Photo Attachment
              const Text(
                'Attach Photo (Optional)',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87), // FIX: Added color
              ),
              const SizedBox(height: 8),
              _buildPhotoPicker(),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitComplaint,
                      icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.send, size: 18),
                      label: _isLoading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('Submit Complaint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87), // FIX: Added color to the label
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black87), // This is for the typed text
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({String? value, required List<String> items, required String label, required String hint, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87), // FIX: Added color to the label
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(color: Colors.black87), // Style for selected item
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select an option.' : null,
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    const priorityMap = {
      'Low': 'Not urgent',
      'Medium': 'Moderate urgency',
      'High': 'Urgent attention needed'
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Level *',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87), // FIX: Added color to the label
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          style: const TextStyle(color: Colors.black87), // Style for selected item
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text('$p - ${priorityMap[p]}'))).toList(),
          onChanged: (val) => setState(() => _selectedPriority = val!),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _imageFile != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose Photo'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Text('Tips for Better Complaints', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('- Be specific about the location and time of the issue.'),
            _buildTip('- Include photos if they help explain the problem.'),
            _buildTip('- Mention if it\'s a recurring issue.'),
            _buildTip('- Set an appropriate priority level.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text, style: TextStyle(color: Colors.brown[800])),
    );
  }
}