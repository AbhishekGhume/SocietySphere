// lib/screens/resident/complaints/new_complaint_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class NewComplaintScreen extends StatefulWidget {
  final String? complaintId; // Optional ID for editing

  const NewComplaintScreen({super.key, this.complaintId});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String _selectedPriority = 'Medium';
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _categories = [
    'Maintenance', 'Security', 'Noise Complaint', 'Parking', 'Cleanliness', 'Utilities', 'Other'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    if (widget.complaintId != null) {
      _isEditMode = true;
      _loadComplaintData();
    }
  }

  Future<void> _loadComplaintData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('complaints').doc(widget.complaintId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        setState(() {
          _selectedCategory = data['category'];
          _selectedPriority = data['priority'] ?? 'Medium';
          _existingImageUrl = data['imageUrl'];
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load complaint data: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in.', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final fileName = path.basename(_imageFile!.path);
        final storageRef = FirebaseStorage.instance.ref().child('complaint_images').child('${DateTime.now().toIso8601String()}_$fileName');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final complaintData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      };

      if (_isEditMode) {
        // --- UPDATE LOGIC ---
        await FirebaseFirestore.instance.collection('complaints').doc(widget.complaintId).update(complaintData);
        _showSnackBar('Complaint updated successfully!', Colors.green);
      } else {
        // --- CREATE LOGIC ---
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        await FirebaseFirestore.instance.collection('complaints').add({
          ...complaintData,
          'status': 'Pending',
          'userId': user.uid,
          'userName': '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'.trim(),
          'flat': userData?['flat'] ?? 'N/A',
          'createdAt': Timestamp.now(),
          'adminResponse': null,
        });
        _showSnackBar('Complaint submitted successfully!', Colors.green);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to save complaint: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(_isEditMode ? 'Edit Complaint' : 'Create Complaint'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildComplaintForm(),
      ),
    );
  }

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
              Text(_isEditMode ? 'Update Your Issue' : 'Submit a New Complaint', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 24),

              _buildTextFormField(controller: _titleController, label: 'Complaint Title *', hint: 'Brief description of the issue'),
              const SizedBox(height: 20),
              _buildDropdownField(value: _selectedCategory, items: _categories, label: 'Category *', hint: 'Select complaint category', onChanged: (val) => setState(() => _selectedCategory = val)),
              const SizedBox(height: 20),
              _buildPriorityDropdown(),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _descriptionController, label: 'Detailed Description *', hint: 'Provide details about the issue...', maxLines: 5),
              const SizedBox(height: 20),

              const Text('Attach Photo (Optional)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildPhotoPicker(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveComplaint,
                  icon: _isLoading ? const SizedBox.shrink() : Icon(_isEditMode ? Icons.update : Icons.send, size: 18),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isEditMode ? 'Update Complaint' : 'Submit Complaint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                  ),
                ),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.black87)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          validator: (value) => value == null ? 'Please select a category.' : null,
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority Level *', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: Colors.black87)))).toList(),
          onChanged: (val) => setState(() => _selectedPriority = val!),
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    Widget imagePreview;
    if (_imageFile != null) {
      imagePreview = Stack(
        children: [
          Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _imageFile = null),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    } else if (_existingImageUrl != null) {
      imagePreview = Stack(
        children: [
          Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _existingImageUrl = null),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    } else {
      imagePreview = Center(
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
      );
    }

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imagePreview,
      ),
    );
  }
}