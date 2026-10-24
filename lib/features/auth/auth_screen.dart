import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/result.dart';
import '../../l10n/l10n.dart';
import '../../state/providers.dart';
import '../../state/session_provider.dart';
import '../../widgets/neon_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _username = TextEditingController();
  bool _register = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final notifier = ref.read(sessionProvider.notifier);
    final result = _register
        ? await notifier.register(
            email: _email.text.trim(),
            password: _password.text,
            username: _username.text.trim().isEmpty ? null : _username.text.trim(),
          )
        : await notifier.signIn(
            email: _email.text.trim(),
            password: _password.text,
          );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result is Success<void>) {
      await ref.read(onboardingProvider.notifier).complete();
      if (mounted) context.go('/');
      return;
    }
    final failure = result as Failure<void>;
    setState(() {
      _error = failure.isNetwork ? context.l10n.endpointUnreachable : context.l10n.authFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: NeonBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('⚡', textAlign: TextAlign.center, style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.appName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          letterSpacing: 4,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  NeonCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(value: false, label: Text(l10n.signIn)),
                              ButtonSegment(value: true, label: Text(l10n.createAccount)),
                            ],
                            selected: {_register},
                            onSelectionChanged: _loading
                                ? null
                                : (value) => setState(() {
                                      _register = value.first;
                                      _error = null;
                                    }),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: _email,
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(labelText: l10n.email),
                            validator: (value) => _emailPattern.hasMatch(value?.trim() ?? '')
                                ? null
                                : l10n.emailInvalid,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _password,
                            enabled: !_loading,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => (value ?? '').length < 8
                                ? l10n.passwordTooShort
                                : null,
                          ),
                          if (_register) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _confirm,
                              enabled: !_loading,
                              obscureText: _obscure,
                              decoration: InputDecoration(labelText: l10n.confirmPassword),
                              validator: (value) =>
                                  value != _password.text ? l10n.passwordMismatch : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _username,
                              enabled: !_loading,
                              decoration: InputDecoration(labelText: l10n.usernameOptional),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!, style: const TextStyle(color: AppColors.danger)),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(_register ? l10n.createAccount : l10n.signIn),
                          ),
                        ],
                      ),
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
}
