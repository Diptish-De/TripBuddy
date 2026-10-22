import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    if (_isSignUp) {
      await notifier.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showGoogleAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Google Authentication',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To use live Google Sign-In with Supabase, you must enable the Google Provider under "Auth -> Providers" in your Supabase Dashboard.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to proceed with the Live Redirect, or use a Simulated/Mock Sign-In for testing?',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signInWithGoogle();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryPurple.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'Live Auth',
              style: TextStyle(color: AppColors.primaryCyan),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signInWithGoogleMock();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text(
              'Simulate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOut,
              ).fadeIn(),

              const SizedBox(height: 32),

              // Header
              Text(
                _isSignUp ? 'Create Account' : 'Welcome Back',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 8),

              Text(
                _isSignUp
                    ? 'Start planning amazing trips with your friends'
                    : 'Sign in to continue your adventures',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isSignUp)
                      TextFormField(
                        controller: _nameController,
                        validator: Validators.displayName,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textTertiary),
                          hintText: 'Enter your name',
                        ),
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),

                    if (_isSignUp) const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textTertiary),
                        hintText: 'your@email.com',
                      ),
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: _obscurePassword,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary),
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
                  ],
                ),
              ),

              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              GradientButton(
                text: _isSignUp ? 'Create Account' : 'Sign In',
                icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                onPressed: authState.isLoading ? null : _submit,
                isLoading: authState.isLoading,
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ).animate(delay: 550.ms).fadeIn(),

              const SizedBox(height: 20),

              // Google Button
              OutlinedButton(
                onPressed: authState.isLoading
                    ? null
                    : _showGoogleAuthDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: AppColors.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.network(
                      'https://www.vectorlogo.zone/logos/google/google-icon.svg',
                      height: 22,
                      width: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isSignUp ? 'Sign up with Google' : 'Sign in with Google',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Toggle
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account?' : "Don't have an account?",
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.primaryCyan),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 650.ms).fadeIn(),

              const SizedBox(height: 16),

              // Demo mode button
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).continueAsDemo();
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18, color: AppColors.accent),
                  label: Text(
                    'Explore in Demo Mode (Offline)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
