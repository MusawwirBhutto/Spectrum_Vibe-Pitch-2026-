import 'package:baalkatwao/api_services/auth_notifier.dart';
import 'package:baalkatwao/api_services/auth_services.dart';
import 'package:baalkatwao/pages/EmailVerificationPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<AuthNotifier>(context, listen: false).userData;
    _usernameController = TextEditingController(text: userData?['username']);
    _emailController = TextEditingController(text: userData?['email']);
    _phoneController = TextEditingController(text: userData?['phone']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final token = authNotifier.authToken;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      final updateData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      // 2. Call the new service method
      final fullUserResponse = await updateUserProfile(
        token: token,
        updatedData: updateData,
      );

      final updatedUserMap = fullUserResponse['user'] ?? fullUserResponse;
      final String? newRole = updatedUserMap['role'] as String?;

      if (newRole == null) {
        throw Exception(
          'Update failed: Missing required user role in server response.',
        );
      }

      authNotifier.setAuthData(token, newRole, updatedUserMap);

      final userAuth = Provider.of<AuthNotifier>(context, listen: false);
      final originalEmail = userAuth.userData?['email'];

      if (originalEmail != _emailController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verify your email to update it.')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(
              email: _emailController.text,
              verificationType: 'Email_Change',
            ),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Update Your Personal Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              _buildTextFormField(
                context: context,
                label: 'username',
                controller: _usernameController,
                icon: Icons.person,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Username cannot be empty.'
                    : null,
                keyboardType: TextInputType.text,
                obscureText: false,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                context: context,
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                validator: (value) =>
                    (value == null || value.isEmpty || !value.contains('@'))
                    ? 'Please enter a valid email'
                    : null,
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                context: context,
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone,
                validator: (value) =>
                    (value == null || value.isEmpty || value.length < 10)
                    ? 'please enter a valid phone number.'
                    : null,
                keyboardType: TextInputType.phone,
                obscureText: false,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextFormField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required String? Function(String?)? validator,
  required TextInputType keyboardType,
  required bool obscureText,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}
