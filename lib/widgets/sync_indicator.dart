import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../domain/enums.dart';
import '../l10n/l10n.dart';
import '../state/providers.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider);
    final (icon, color, label) = switch (state.status) {
      SyncStatus.idle => (Icons.cloud_done_outlined, AppColors.success, context.l10n.syncIdle),
      SyncStatus.pending => (
          Icons.cloud_upload_outlined,
          AppColors.warning,
          context.l10n.syncPending(state.pendingCount),
        ),
      SyncStatus.syncing => (Icons.cloud_sync_outlined, AppColors.primary, context.l10n.syncSyncing),
      SyncStatus.error => (Icons.cloud_off, AppColors.danger, context.l10n.syncError),
    };
    if (compact) {
      return Tooltip(
        message: state.error ?? label,
        child: Icon(icon, size: 18, color: color),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class OfflineStrip extends StatelessWidget {
  const OfflineStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.warning.withValues(alpha: 0.14),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 14, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.offlineShowingCached,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
          const SyncIndicator(compact: true),
        ],
      ),
    );
  }
}
