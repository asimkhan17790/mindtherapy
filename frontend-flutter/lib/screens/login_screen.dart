import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/affirmation_provider.dart';
import '../app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MT.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo + name
                  Column(
                    children: [
                      const MTLogoMark(size: 60),
                      const SizedBox(height: 20),
                      Text('MINDTHERAPY', style: MT.eyebrow()),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Affirmation quote
                  Consumer<AffirmationProvider>(
                    builder: (context, prov, _) {
                      final msg = prov.todaysAffirmation?.cleanMessage ??
                          'A small check-in can change\nthe whole day.';
                      return Column(
                        children: [
                          Text('AFFIRMATION · TODAY', style: MT.eyebrow()),
                          const SizedBox(height: 18),
                          Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: MT.headlineLg(),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '— a gentle thought, from you to you',
                            style: MT.body(color: MT.ink3).copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(flex: 3),

                  // Auth buttons
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Column(
                        children: [
                          MTFilledButton(
                            label: 'Continue with Google',
                            loading: auth.isLoading,
                            onTap: () async {
                              final ok = await auth.signInWithGoogle();
                              if (ok && context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Sign in failed. Try again.'),
                                    backgroundColor: MT.ink,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          MTGhostButton(
                            label: 'Continue as guest',
                            onTap: () async {
                              await auth.signInAsGuest();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Text('Privacy · Terms', style: MT.meta()),
                        ],
                      );
                    },
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
