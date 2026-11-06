import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive.dart';
import '../widgets/techyd_wordmark.dart';

/// Login and sign-up share one validated form screen.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.signUp});
  final bool signUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final err = widget.signUp
        ? await auth.signUp(_name.text, _email.text, _password.text)
        : await auth.login(_email.text, _password.text);
    if (!mounted) return;

    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final size = screenSizeOf(context);
    final split = size != ScreenSize.mobile && MediaQuery.of(context).size.width >= 900;
    final signUp = widget.signUp;

    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FadeSlideIn(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!split) ...[
                    const TechydWordmark(size: 22),
                    const SizedBox(height: 36),
                  ],
                  Text(
                    signUp ? 'CREATE\nACCOUNT' : 'WELCOME\nBACK',
                    style: display(context, size: 40, height: 1),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    signUp
                        ? 'Register for events, save favourites and track your tickets.'
                        : 'Sign in to see your tickets and bookmarks.',
                    style: TextStyle(color: p.muted, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  if (signUp) ...[
                    CustomTextField(
                      label: 'Full name',
                      icon: Icons.person_outline_rounded,
                      controller: _name,
                      validator: Validators.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomTextField(
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _password,
                    obscure: true,
                    validator: signUp
                        ? Validators.password
                        : (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                  ),
                  if (signUp) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Confirm password',
                      icon: Icons.lock_reset_rounded,
                      controller: _confirm,
                      obscure: true,
                      validator: Validators.confirmPassword(() => _password.text),
                    ),
                  ],
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: _error == null
                        ? const SizedBox(width: double.infinity)
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5C5C).withAlpha(28),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFF5C5C).withAlpha(120)),
                            ),
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Color(0xFFFF7A7A), fontSize: 13)),
                          ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: signUp ? 'Create account' : 'Sign in',
                    expand: true,
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, signUp ? Routes.login : Routes.signup),
                      style: TextButton.styleFrom(foregroundColor: p.muted),
                      child: Text(signUp
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, Routes.home, (r) => false),
                      style: TextButton.styleFrom(foregroundColor: p.muted),
                      child: const Text('Continue as guest'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      extendBodyBehindAppBar: split,
      body: split
          ? Row(
              children: [
                Expanded(flex: 5, child: _ImagePanel(signUp: signUp)),
                Expanded(flex: 4, child: form),
              ],
            )
          : SafeArea(child: form),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.signUp});
  final bool signUp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/hyd_night.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Pal.dark.surface),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(140),
                Colors.black.withAlpha(60),
                Colors.black.withAlpha(230),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TechydWordmark(size: 26, color: Colors.white),
              const Spacer(),
              Text(
                'NEVER MISS\nA HYDERABAD\nTECH EVENT.',
                style: display(
                  context,
                  size: 46,
                  color: Colors.white,
                  weight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
