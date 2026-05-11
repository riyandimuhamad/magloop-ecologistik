import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/schedule_item.dart';
import '../widgets/mps_card.dart';
import 'scanner_screen.dart';

// ─── Dummy Data ────────────────────────────────────────────────────────────
final List<ScheduleItem> _dummySchedules = [
  ScheduleItem(
    id: 'MPS-001',
    partnerName: 'Restoran Nusantara',
    partnerType: 'HOREKA',
    pickupTime: '07:00 – 08:30',
    location: 'Jl. Sudirman No. 45, Jakarta Pusat',
    status: ScheduleStatus.inTransit,
    commodity: 'Sisa Organik',
    weightKg: 120.5,
  ),
  ScheduleItem(
    id: 'MPS-002',
    partnerName: 'Dapur MBG Ciputat',
    partnerType: 'Dapur MBG',
    pickupTime: '08:00 – 09:00',
    location: 'Jl. Ciputat Raya No. 12, Tangerang Selatan',
    status: ScheduleStatus.pending,
    commodity: 'Sampah Dapur',
    weightKg: 85.0,
  ),
  ScheduleItem(
    id: 'MPS-003',
    partnerName: 'Hotel Borobudur Jakarta',
    partnerType: 'HOREKA',
    pickupTime: '06:30 – 07:30',
    location: 'Jl. Lapangan Banteng Selatan, Jakarta Pusat',
    status: ScheduleStatus.completed,
    commodity: 'Limbah Organik',
    weightKg: 210.0,
  ),
  ScheduleItem(
    id: 'MPS-004',
    partnerName: 'Dapur MBG Bekasi',
    partnerType: 'Dapur MBG',
    pickupTime: '09:00 – 10:00',
    location: 'Jl. Ahmad Yani No. 78, Bekasi',
    status: ScheduleStatus.pending,
    commodity: 'Sisa Bahan Makanan',
    weightKg: 65.0,
  ),
  ScheduleItem(
    id: 'MPS-005',
    partnerName: 'Kafe Ekologi',
    partnerType: 'HOREKA',
    pickupTime: '10:30 – 11:30',
    location: 'Jl. Kemang Raya No. 99, Jakarta Selatan',
    status: ScheduleStatus.completed,
    commodity: 'Ampas Kopi & Organik',
    weightKg: 32.0,
  ),
];

// ─── Schedule / Dashboard Screen ──────────────────────────────────────────
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua', 'Pending', 'In-Transit', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ScheduleItem> _filtered(int tabIndex) {
    if (tabIndex == 0) return _dummySchedules;
    final statusMap = {
      1: ScheduleStatus.pending,
      2: ScheduleStatus.inTransit,
      3: ScheduleStatus.completed,
    };
    return _dummySchedules
        .where((s) => s.status == statusMap[tabIndex])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerificationScanner()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Verifikasi Setor'),
      ),
      body: SelectionArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          // ── AppBar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            expandedHeight: 140,
            elevation: 0,
            scrolledUnderElevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Text(
                      _formatToday(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Master Production\nSchedule',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                          ),
                        ),
                        // Summary Chips
                        _SummaryChip(
                          count: _dummySchedules
                              .where(
                                (s) => s.status == ScheduleStatus.inTransit,
                              )
                              .length,
                          label: 'Aktif',
                          color: AppColors.statusInTransit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textTertiary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  dividerColor: AppColors.border,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),

          // ── Stats Summary Row ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _StatCard(
                    value: _dummySchedules.length.toString(),
                    label: 'Total Jadwal',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: _dummySchedules
                        .where((s) => s.status == ScheduleStatus.completed)
                        .length
                        .toString(),
                    label: 'Selesai',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.statusCompleted,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value:
                        '${_dummySchedules.fold(0.0, (sum, s) => sum + (s.weightKg ?? 0)).toStringAsFixed(0)} kg',
                    label: 'Total Berat',
                    icon: Icons.scale_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // ── Section Label ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Hari Ini',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final count = _filtered(_tabController.index).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$count item',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── MPS Card List ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final items = _filtered(_tabController.index);
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(tabName: _tabs[_tabController.index]),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        index == items.length - 1 ? 120 : 12,
                      ),
                      child: MpsCard(
                        item: items[index],
                        onTap: () => _showDetailSheet(context, items[index]),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              );
            },
          ),
        ],
      ),),
    );
  }

  // ── Detail Bottom Sheet ──────────────────────────────────────────────────
  void _showDetailSheet(BuildContext context, ScheduleItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetailSheet(item: item),
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String tabName;
  const _EmptyState({required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal $tabName',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jadwal akan muncul di sini\nsaat tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final ScheduleItem item;
  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.partnerName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.id,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                // Details
                _DetailRow(
                  icon: Icons.business_rounded,
                  label: 'Tipe Mitra',
                  value: item.partnerType,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Jam Penjemputan',
                  value: item.pickupTime,
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi',
                  value: item.location,
                ),
                if (item.commodity != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.eco_rounded,
                    label: 'Komoditas',
                    value: item.commodity!,
                  ),
                ],
                if (item.weightKg != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.scale_rounded,
                    label: 'Estimasi Berat',
                    value: '${item.weightKg} kg',
                  ),
                ],
                const SizedBox(height: 24),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('Mulai Navigasi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
