// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/auth/login_screen.dart';
import 'package:society_manager/screens/auth/pending_approval_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _societyIdController = TextEditingController();
  // NEW: Controller for the mobile number field
  final TextEditingController _mobileController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _flatController.dispose();
    _societyIdController.dispose();
    // NEW: Dispose the mobile controller
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 40,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  _buildSignUpCard(isSmallScreen),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4285F4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.article_outlined,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'SocietySphere',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Join your community today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpCard(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? double.infinity : 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fill in your details to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFirstNameField(),
          const SizedBox(height: 20),
          _buildLastNameField(),
          const SizedBox(height: 20),
          _buildFlatField(),
          const SizedBox(height: 20),
          _buildSocietyIdField(),
          const SizedBox(height: 20),
          // NEW: Added Mobile No. field
          _buildMobileField(),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(),
          const SizedBox(height: 32),
          _buildSignUpButton(),
          const SizedBox(height: 24),
          _buildSignInLink(),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return _buildTextField(
      label: 'First Name',
      controller: _firstNameController,
      icon: Icons.person_outline,
      hint: 'Enter your first name',
    );
  }

  Widget _buildLastNameField() {
    return _buildTextField(
      label: 'Last Name',
      controller: _lastNameController,
      icon: Icons.person_outline,
      hint: 'Enter your last name',
    );
  }

  Widget _buildFlatField() {
    return _buildTextField(
      label: 'Flat No.',
      controller: _flatController,
      icon: Icons.home_outlined,
      hint: 'e.g., A-101',
    );
  }

  Widget _buildSocietyIdField() {
    return _buildTextField(
      label: 'Society ID',
      controller: _societyIdController,
      icon: Icons.location_city_outlined,
      hint: 'Enter your society ID',
    );
  }

  // NEW: Widget for Mobile No. field
  Widget _buildMobileField() {
    return _buildTextField(
      label: 'Mobile No.',
      controller: _mobileController,
      icon: Icons.phone_outlined,
      hint: 'Enter your mobile number',
      inputType: TextInputType.phone,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      label: 'Email Address',
      controller: _emailController,
      icon: Icons.email_outlined,
      hint: 'Enter your email',
      inputType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildPasswordInput(
      label: 'Password',
      controller: _passwordController,
      hint: 'Create a password',
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildPasswordInput(
      label: 'Confirm Password',
      controller: _confirmPasswordController,
      hint: 'Re-enter your password',
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Create Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: _handleSignIn,
                child: const Text(
                  'Sign in here',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    // NEW: Added validation for mobile number
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _flatController.text.isEmpty ||
        _societyIdController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCred.user;

      if (user != null) {
        // NEW: Save mobile number to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'flat': _flatController.text.trim(),
          'societyId': _societyIdController.text.trim(),
          'phone': _mobileController.text.trim(),
          'email': _emailController.text.trim(),
          'roles': ['resident'],
          'isActive': false,
          'profilePicture': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'fcmToken': null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Wait for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  const PendingApprovalScreen())
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'Signup failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSignIn() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
