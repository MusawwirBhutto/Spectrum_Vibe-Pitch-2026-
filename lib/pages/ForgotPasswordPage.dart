import 'package:baalkatwao/api_services/auth_services.dart';
import 'package:baalkatwao/pages/EmailVerificationPage.dart';
import 'package:baalkatwao/pages/ProfilePage.dart';
import 'package:baalkatwao/themes/themes.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- API Call and Navigation (Logic unchanged) ---
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await sendVerificationCode(
        email: _emailController.text.trim(),
        verificationType: 'Password_reset',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent successfully!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(
            email: _emailController.text.trim(),
            verificationType: 'Password_reset',
          ),
        ),
      );
    } catch (e) {
      // Use the error color from the theme palette for consistency
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorRed, // Use theme color for clarity
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme is applied implicitly via Scaffold and AppBar
    return Scaffold(
      appBar: AppBar(
        // The title style is automatically picked up from appTheme.appBarTheme.titleTextStyle
        title: const Text('Forgot Password'),
        // Removed: backgroundColor: Colors.transparent, elevation: 0, -> Handled by theme
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Custom Header
                Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  // Use theme's headlineLarge for primary screen title
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the email address associated with your account and we will send you a verification code.',
                  textAlign: TextAlign.center,
                  // Use theme's bodySmall for secondary description text
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 48),

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      // Use theme's primary color for the icon accent
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Removed all explicit border/fill/hint styles -> Handled by theme's inputDecorationTheme
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          // Use theme's primary color for the loader
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitRequest,
                        // Removed style: ElevatedButton.styleFrom(...)
                        // The theme's elevatedButtonTheme automatically applies
                        // the Purple background, white text, and premium padding/shape/shadow.
                        child: Text(
                          'Send Verification Code',
                          // Text style is automatically picked up from theme's button theme
                        ),
                      ),
                const SizedBox(height: 20),

                // Return to Login link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the login screen
                  },
                  child: Text(
                    'Remembered your password? Login',
                    // Use theme's primary color for the link
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//--------------------------------------------choose new password page--------------------------------------

// ignore: must_be_immutable
class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- API Method Skeleton (Logic unchanged) ---
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await resetPassword(
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
        email: widget.email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Password updated successfully! Please log in.',
            ),
            backgroundColor:
                AppColors.successGreen, // Use theme color for clarity
          ),
        );

        // Navigate back to the login screen and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfilePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
            backgroundColor: AppColors.errorRed, // Use theme color for clarity
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- UI Building Helper (Theme integration applied here) ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    // Access the primary color for dynamic elements
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      keyboardType: TextInputType.visiblePassword,
      validator: validator,
      // Removed custom style: const TextStyle(color: Colors.black87) -> Handled by theme's bodyMedium
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(
              context,
            ).textTheme.bodySmall!.color, // Use theme's light text color
          ),
          onPressed: toggleVisibility,
        ),
        // Removed all explicit border/fill/focus styles -> Handled by theme's inputDecorationTheme
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title style is automatically picked up from appTheme.appBarTheme.titleTextStyle
        title: const Text('New Password'),
        // Removed: backgroundColor: Colors.transparent, elevation: 0, -> Handled by theme
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Header
                Text(
                  'Set New Password',
                  textAlign: TextAlign.center,
                  // Use theme's headlineLarge for primary screen title
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your OTP was verified. Enter a new, secure password below.',
                  textAlign: TextAlign.center,
                  // Use theme's bodySmall for secondary description text
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 48),

                // New Password Field
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  isVisible: _isNewPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  isVisible: _isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Reset Button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          // Use theme's primary color for the loader
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        // Removed style: ElevatedButton.styleFrom(...)
                        // The theme's elevatedButtonTheme automatically applies
                        // the Purple background, white text, and premium padding/shape/shadow.
                        child: const Text(
                          'Reset Password',
                          // Text style is automatically picked up from theme's button theme
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
