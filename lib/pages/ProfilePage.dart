// ignore_for_file: file_names, use_super_parameters
import 'package:baalkatwao/Business/OnBoardingPage.dart';
import 'package:baalkatwao/api_services/auth_notifier.dart';
import 'package:baalkatwao/pages/MainNavigationPage.dart';
import 'package:baalkatwao/api_services/auth_services.dart';
import 'package:baalkatwao/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const AuthenticatedProfileView();
        } else {
          return const UnauthenticatedLoginView();
        }
      },
    );
  }
}

class UnauthenticatedLoginView extends StatefulWidget {
  const UnauthenticatedLoginView({super.key});

  @override
  State<UnauthenticatedLoginView> createState() =>
      _UnauthenticatedLoginViewState();
}

class _UnauthenticatedLoginViewState extends State<UnauthenticatedLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        final loginResponse = await loginUser(email: email, password: password);
        final token = loginResponse['token'];

        final userDataResponse = await getLoggedInUser(token);
        final user = userDataResponse['user'];
        final role = user['role'];
        print('$user');

        final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
        await authNotifier.setAuthData(token, role, user);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));

          if (authNotifier.isBusiness) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Onboardingpage()),
              (route) => false,
            );
          }
          if (authNotifier.isCustomer) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationPage(initialindex: 0),
              ),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome! ",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                "Your next amazing look awaits. ",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Log in to your account.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.forgotpasswordpage);
                },
                child: Text(
                  "Forgot Password?",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Log In"),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.signuppage);
                    },
                    child: Text(
                      "Sign Up",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
}

class AuthenticatedProfileView extends StatefulWidget {
  const AuthenticatedProfileView({super.key});

  @override
  State<AuthenticatedProfileView> createState() =>
      _AuthenticatedProfileViewState();
}

class _AuthenticatedProfileViewState extends State<AuthenticatedProfileView> {
  String? profilePicUrl; // Local state for cache-busted URL

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final userData = auth.userData;

    if (userData != null) {
      final url = userData['profile_pic'] ?? '';
      if (url.isNotEmpty) {
        profilePicUrl = '$url?v=${DateTime.now().millisecondsSinceEpoch}';
      }
    }
  }

  // Logout
  void _handleLogout(BuildContext context) {
    Provider.of<AuthNotifier>(context, listen: false).clearAuthData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationPage(initialindex: 0),
      ),
      (route) => false,
    );
  }

  // Change Profile Picture
  Future<void> _changeProfilePicture(BuildContext context) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final String? token = authNotifier.authToken;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in.')),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Uploading profile picture... Please wait...'),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final result = await uploadProfileImage(
        token: token,
        imageFile: pickedFile,
      );

      final newImageUrl = result['imageUrl'] as String;

      final freshUrl =
          '$newImageUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        profilePicUrl = freshUrl;
      });

      authNotifier.setAuthData(
        authNotifier.authToken!,
        authNotifier.userRole!,
        {...?authNotifier.userData, 'profile_pic': newImageUrl},
      );

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context, listen: true);
    final userData = auth.userData;

    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String name = userData['username'] ?? 'No Name';
    final String email = userData['email'] ?? 'No Email';
    final bool isBusiness = auth.isBusiness;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              "Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Profile Picture + Edit button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      (profilePicUrl != null && profilePicUrl!.isNotEmpty)
                      ? NetworkImage(profilePicUrl!)
                      : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: (profilePicUrl == null || profilePicUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _changeProfilePicture(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            Text(email, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              auth.userRole == 'BUSINESS'
                  ? 'Account Type: Business'
                  : 'Account Type: Customer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isBusiness ? Colors.green : Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            if (!isBusiness)
              _buildProfileOption(
                context,
                'Favourite Salons',
                Icons.favorite_border,
              ),

            _buildProfileOption(context, 'Settings', Icons.settings_outlined),

            _buildProfileOption(context, 'Edit profile', Icons.person),

            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (title == 'Edit profile') {
          Navigator.pushNamed(context, Routes.editprofilepage);
        } else if (title == 'Settings') {
          Navigator.pushNamed(context, Routes.settingspage);
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Log Out'),
      ),
    );
  }
}
