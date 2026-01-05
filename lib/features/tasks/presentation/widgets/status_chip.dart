import 'package:flutter/material.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/design_system/spacing.dart';
import '../../../../core/design_system/typography.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'BERJALAN':
        return AppColors.statusBerjalan;
      case 'SELESAI':
        return AppColors.statusSelesai;
      case 'TERLAMBAT':
        return AppColors.statusTerlambat;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status) {
      case 'BERJALAN':
        return AppColors.statusBerjalaanBg;
      case 'SELESAI':
        return AppColors.statusSelesaiBg;
      case 'TERLAMBAT':
        return AppColors.statusTerlambatBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'BERJALAN':
        return Icons.play_circle_outline;
      case 'SELESAI':
        return Icons.check_circle_outline;
      case 'TERLAMBAT':
        return Icons.warning_amber_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: AppSpacing.iconSm,
            color: _getStatusColor(),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status,
            style: AppTypography.captionBold.copyWith(color: _getStatusColor()),
          ),
        ],
      ),
    );
  }
}
