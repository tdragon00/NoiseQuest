import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/result.dart';
import '../../data/remote/api_client.dart';
import '../../data/remote/meta_api.dart';
import '../../l10n/l10n.dart';
import '../../services/endpoint_service.dart';
import '../../state/providers.dart';
import '../../widgets/neon_card.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  late final TextEditingController _controller;
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(endpointProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _error = null;
      _testing = true;
    });
    final raw = _controller.text.trim();
    final validation = EndpointService.validate(raw);
    if (validation != null) {
      setState(() {
        _testing = false;
        _error = context.l10n.endpointInvalid;
      });
      return;
    }
    final result = await ref.read(endpointServiceProvider).test(raw);
    if (!mounted) return;
    if (result case Success<HealthInfo>()) {
      await ref.read(endpointProvider.notifier).setEndpoint(raw, markLaunched: false);
      if (!mounted) return;
      setState(() => _testing = false);
      context.go('/language');
      return;
    }
    final failure = result as Failure<HealthInfo>;
    setState(() {
      _testing = false;
      _error = failure.isNetwork ? context.l10n.endpointUnreachable : failure.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '⚡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 56,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.appName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          letterSpacing: 6,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  NeonCard(
                    accent: AppColors.primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.serverEndpoint,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                          enabled: !_testing,
                          decoration: InputDecoration(
                            hintText: context.l10n.endpointHint,
                            errorText: _error,
                          ),
                          onSubmitted: (_) => _continue(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _testing ? null : _continue,
                          child: _testing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(context.l10n.testingConnection),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(context.l10n.continueLabel),
                                    const SizedBox(width: AppSpacing.sm),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          context.l10n.defaultEndpoint(kDefaultEndpoint),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
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
}
