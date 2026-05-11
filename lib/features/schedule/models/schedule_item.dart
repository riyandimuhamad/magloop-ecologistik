import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─── Schedule Status Enum ──────────────────────────────────────────────────
enum ScheduleStatus { pending, inTransit, completed }

extension ScheduleStatusExtension on ScheduleStatus {
  String get label {
    switch (this) {
      case ScheduleStatus.pending:
        return 'Pending';
      case ScheduleStatus.inTransit:
        return 'In-Transit';
      case ScheduleStatus.completed:
        return 'Completed';
    }
  }

  Color get badgeColor {
    switch (this) {
      case ScheduleStatus.pending:
        return AppColors.statusPending;
      case ScheduleStatus.inTransit:
        return AppColors.statusInTransit;
      case ScheduleStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  Color get badgeSurface {
    switch (this) {
      case ScheduleStatus.pending:
        return AppColors.statusPendingSurface;
      case ScheduleStatus.inTransit:
        return AppColors.statusInTransitSurface;
      case ScheduleStatus.completed:
        return AppColors.statusCompletedSurface;
    }
  }

  IconData get icon {
    switch (this) {
      case ScheduleStatus.pending:
        return Icons.schedule_rounded;
      case ScheduleStatus.inTransit:
        return Icons.local_shipping_rounded;
      case ScheduleStatus.completed:
        return Icons.check_circle_rounded;
    }
  }
}

// ─── Schedule Item Model ───────────────────────────────────────────────────
class ScheduleItem {
  final String id;
  final String partnerName;
  final String partnerType; // HOREKA / Dapur MBG
  final String pickupTime;
  final String location;
  final ScheduleStatus status;
  final String? commodity;
  final double? weightKg;

  const ScheduleItem({
    required this.id,
    required this.partnerName,
    required this.partnerType,
    required this.pickupTime,
    required this.location,
    required this.status,
    this.commodity,
    this.weightKg,
  });
}
