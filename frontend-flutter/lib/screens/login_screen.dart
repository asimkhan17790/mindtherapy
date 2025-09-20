import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // App Logo/Icon
                Icon(
                  Icons.favorite_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),

                // App Title
                Text(
                  'MindTherapy',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Your personal mental wellness companion',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // Sign in with Google button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ElevatedButton(
                      onPressed: () async {
                        final success = await authProvider.signInWithGoogle();
                        if (success && mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sign in failed. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_logo.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.login,
                                size: 24,
                                color: Colors.blue,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Privacy notice
                Text(
                  'By signing in, you agree to our Terms of Service and Privacy Policy',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Features preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'What you\'ll get:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Daily affirmations',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.mood_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mood tracking',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Personalized suggestions',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
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