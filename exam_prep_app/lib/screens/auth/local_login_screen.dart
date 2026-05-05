import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/local_auth_provider.dart';
import '../../widgets/common_widgets.dart';

/// Local Login Screen - For testing without Firebase
class LocalLoginScreen extends StatefulWidget {
  const LocalLoginScreen({super.key});

  @override
  State<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends State<LocalLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
      final success = await authProvider.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        final user = authProvider.currentUser;
        if (user != null) {
          _navigateBasedOnRole(user['role']);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateBasedOnRole(String? role) {
    switch (role) {
      case 'sme':
        Navigator.pushReplacementNamed(context, '/sme-dashboard');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'PlanB',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Exam Prep App',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: AppTextStyles.headline2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: AppInputs.textField(
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          decoration: AppInputs.textField(
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outlined,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: AppButtons.primary,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Demo Login Buttons
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Quick Demo Login',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _DemoLoginButton(
                              label: 'User',
                              color: AppColors.primary,
                              onTap: () => _demoLogin('user1', 'password', 'user'),
                            ),
                            _DemoLoginButton(
                              label: 'SME',
                              color: AppColors.smePrimary,
                              onTap: () => _demoLogin('sme1', 'password', 'sme'),
                            ),
                            _DemoLoginButton(
                              label: 'Admin',
                              color: AppColors.adminPrimary,
                              onTap: () => _demoLogin('admin1', 'password', 'admin'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Password: password (for all)',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _demoLogin(String email, String password, String role) async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
      final user = await authProvider.signInWithEmail('$email@planb.com', password);
      
      if (user != null && mounted) {
        _navigateBasedOnRole(role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _DemoLoginButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DemoLoginButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}