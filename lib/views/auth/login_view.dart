import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  // Cached reference so dispose() never calls context.read() on a dead widget.
  late AuthController _authCtrl;

  @override
  void initState() {
    super.initState();
    // Cache the controller and attach the listener after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authCtrl = context.read<AuthController>();
      _authCtrl.addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    // Use the cached reference — context is unsafe in dispose().
    _authCtrl.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    // Guard first: if the widget has left the tree, do nothing.
    if (!mounted) return;
    final ctrl = _authCtrl;
    if (ctrl.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ctrl.errorMessage!,
            style: AppFonts.body(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
      ctrl.clearError();
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final role = await context.read<AuthController>().login(
      _emailCtrl.text,
      _passCtrl.text,
    );
    if (role != null && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Dark top half ──────────────────────────────────────────────
            SizedBox(
              height: screenHeight * 0.40,
              child: Stack(
                children: [
                  // Radial glow blob
                  Positioned(
                    top: -80,
                    left: -60,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: AppColors.glowPurple.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            // decoration: BoxDecoration(
                            //   color: AppColors.primary,
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/pawhealth_logo.png',
                                width: 100,
                                height: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'PawHealth',
                            style: AppFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Your pet's health, simplified.",
                            style: AppFonts.serifItalic(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue',
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.navInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── White bottom card ──────────────────────────────────────────
            Container(
              constraints: BoxConstraints(minHeight: screenHeight * 0.60),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Email ──
                    Text('EMAIL', style: AppFonts.label()),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: AppFonts.body(),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: AppFonts.body(color: AppColors.navInactive),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.mutedText,
                          size: 20,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // ── Password ──
                    Text('PASSWORD', style: AppFonts.label()),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      style: AppFonts.body(),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: AppFonts.body(color: AppColors.navInactive),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.mutedText,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.mutedText,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your password';
                        if (v.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    // ── Forgot password ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: AppFonts.dmSans(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // ── Login button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: AppDecor.ctaButton(),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Login', style: AppFonts.button()),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Divider ──
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.cardBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: AppFonts.caption(
                              color: AppColors.navInactive,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.cardBorder)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Social buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: AppDecor.outlineButton(),
                            icon: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: Text(
                              'Google',
                              style: AppFonts.body(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: AppDecor.outlineButton(),
                            icon: Icon(Icons.apple, size: 20),
                            label: Text(
                              'Apple',
                              style: AppFonts.body(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Sign-up link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppFonts.body(
                            color: AppColors.metaText,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterView(),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
