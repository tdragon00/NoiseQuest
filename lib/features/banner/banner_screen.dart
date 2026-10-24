import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/banner_presets.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/result.dart';
import '../../domain/user.dart';
import '../../l10n/l10n.dart';
import '../../state/providers.dart';
import '../../state/session_provider.dart';
import '../../widgets/banner_card.dart';
import '../../widgets/banner_painter.dart';
import '../../widgets/emoji_picker.dart';
import '../../widgets/neon_card.dart';

class BannerScreen extends ConsumerStatefulWidget {
  const BannerScreen({super.key});

  @override
  ConsumerState<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends ConsumerState<BannerScreen> {
  String? _presetId;
  String? _avatar;
  bool _clearAvatar = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(sessionProvider).user;
    _presetId ??= user?.bannerPresetId ?? 'neon_grid';
    _avatar ??= user?.avatar;
  }

  Future<void> _save(User user) async {
    setState(() => _saving = true);
    final result = await ref.read(sessionProvider.notifier).updateProfile(
          bannerPresetId: _presetId,
          avatar: _avatar,
          clearAvatar: _clearAvatar,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Success<User>) {
      final messenger = ScaffoldMessenger.of(context);
      final savedText = context.l10n.bannerSaved;
      context.go('/');
      messenger.showSnackBar(SnackBar(content: Text(savedText)));
    } else {
      final failure = result as Failure<User>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider).user;
    final table = ref.watch(levelTableProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final presetId = _presetId ?? user.bannerPresetId;
    final level = table.level(user.totalXp);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bannerEditor),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: FilledButton(
              onPressed: _saving ? null : () => _save(user),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.preview, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          BannerView(
            displayName: user.displayName,
            avatar: _clearAvatar ? null : (_avatar ?? user.avatar),
            level: level,
            title: table.title(user.totalXp),
            totalXp: user.totalXp,
            presetId: presetId,
            levelTable: table,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.avatar, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                onTap: () async {
                  final picked = await showEmojiPicker(
                    context,
                    selected: _avatar,
                    avatarsOnly: true,
                  );
                  if (picked == null) return;
                  setState(() {
                    if (picked.isEmpty) {
                      _clearAvatar = true;
                      _avatar = null;
                    } else {
                      _clearAvatar = false;
                      _avatar = picked;
                    }
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    _clearAvatar ? '✦' : (_avatar ?? user.avatar ?? '✦'),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(context.l10n.profilePicture),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(l10n.artPresets, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(
                l10n.bannerLockedNote,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 560 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kBannerPresets.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final preset = kBannerPresets[index];
                  final selected = preset.id == presetId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () => setState(() => _presetId = preset.id),
                    child: NeonCard(
                      padding: EdgeInsets.zero,
                      accent: selected ? preset.accent : AppColors.outline,
                      selected: selected,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            painter: NeonBannerPainter(preset: preset),
                          ),
                          Container(
                            color: AppColors.bg.withValues(alpha: 0.25),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              preset.name,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: AppSpacing.xs,
                              right: AppSpacing.xs,
                              child: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: preset.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
