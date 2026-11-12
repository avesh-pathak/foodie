import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/foodie_logo.dart';
import '../widgets/foodie_page_route.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    FoodieScope.of(context).login(identity: _identityController.text);
    Navigator.of(context).pushAndRemoveUntil(
      FoodiePageRoute<void>(page: const MainShell()),
      (Route<dynamic> route) => false,
    );
  }

  void _useDemoAccount() {
    _identityController.text = 'Avesh';
    _passwordController.text = 'foodie';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.foodie.background,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxHeight < 760;
          return Stack(
            children: <Widget>[
              Positioned(
                top: -90,
                right: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: context.foodie.primarySoft.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -70,
                bottom: 40,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: context.foodie.primarySofter.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      compact ? 4 : 8,
                      20,
                      compact ? 10 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: () => Navigator.of(context).maybePop(),
                                tooltip: 'Back',
                                style: IconButton.styleFrom(
                                  backgroundColor: context.foodie.surface,
                                  side: BorderSide(color: context.foodie.border),
                                  minimumSize: const Size(40, 40),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 19,
                                ),
                              ),
                              const Spacer(),
                              FoodieLogo(size: compact ? 34 : 38),
                            ],
                          ),
                          SizedBox(height: compact ? 18 : 26),
                          Text(
                            compact
                                ? 'Welcome to\nFoodie.'
                                : 'Welcome to\nyour happy place.',
                            style: context.foodieType.display.copyWith(
                              fontSize: compact ? 34 : 38,
                            ),
                          ),
                          SizedBox(height: compact ? 7 : 10),
                          Text(
                            compact
                                ? 'Sign in with any name, phone or email. No OTP, no verification.'
                                : 'Sign in with any name, phone number or email. This is a demo — no OTP and no verification.',
                            style: context.foodieType.bodyMuted.copyWith(
                              height: 1.45,
                              fontSize: compact ? 12.5 : 14,
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 24),
                          Container(
                            padding: EdgeInsets.all(compact ? 16 : 20),
                            decoration: BoxDecoration(
                              color: context.foodie.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.lg,
                              ),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Your details',
                                    style: context.foodieType.h2.copyWith(
                                      fontSize: compact ? 18 : 19,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 10 : 16),
                                  TextFormField(
                                    controller: _identityController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.words,
                                    autofillHints: const <String>[
                                      AutofillHints.name,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Name, phone or email',
                                      hintText: 'e.g. Avesh',
                                      isDense: compact,
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: context.foodie.primaryInk,
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a name, phone or email.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 8 : 12),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _continue(),
                                    decoration: InputDecoration(
                                      labelText: compact
                                          ? 'Password'
                                          : 'Password (optional)',
                                      hintText: 'Anything works here',
                                      isDense: compact,
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: context.foodie.primaryInk,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 20,
                                          color: context.foodie.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 12 : 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: compact ? 48 : 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _continue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            context.foodie.primary,
                                        foregroundColor:
                                            context.foodie.onPrimary,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 21,
                                              height: 21,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color:
                                                    context.foodie.onPrimary,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(
                                                    compact
                                                        ? 'Continue'
                                                        : 'Continue to Foodie',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 19,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 2 : 6),
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: _useDemoAccount,
                                      style: TextButton.styleFrom(
                                        visualDensity: compact
                                            ? VisualDensity.compact
                                            : VisualDensity.standard,
                                      ),
                                      icon: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Fill demo details'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          if (compact)
                            Center(
                              child: Text(
                                'Demo mode • any input works • no data leaves this device',
                                textAlign: TextAlign.center,
                                style: context.foodieType.small.copyWith(
                                  fontSize: 9.5,
                                  color: context.foodie.subtle,
                                ),
                              ),
                            )
                          else ...<Widget>[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.foodie.surfaceWarm.withValues(
                                  alpha: 0.75,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                border: Border.all(color: context.foodie.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: context.foodie.primaryInk,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'Demo mode: no real authentication is performed and your details never leave this device.',
                                      style: context.foodieType.small.copyWith(
                                        color: context.foodie.ink,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Text(
                                'By continuing you agree to our demo terms.',
                                style: context.foodieType.small.copyWith(
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
