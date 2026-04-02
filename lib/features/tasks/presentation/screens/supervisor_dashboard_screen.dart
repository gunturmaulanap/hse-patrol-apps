import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../providers/task_provider.dart';

enum _DashboardMode { area, staff }

class SupervisorDashboardScreen extends ConsumerStatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  ConsumerState<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends ConsumerState<SupervisorDashboardScreen> {
  static const List<int> _pageSizes = [5, 10, 20];

  _DashboardMode _mode = _DashboardMode.area;

  String? _selectedArea;
  String? _selectedStaff;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  int _page = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final areasAsync = ref.watch(areasFutureProvider);
    final tasksAsync = ref.watch(supervisorAllVisibleTaskMapsProvider);

    if (user == null || user.role != 'supervisor') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goNamed(RouteNames.login);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allTasks = [...(tasksAsync.valueOrNull ?? <Map<String, dynamic>>[])]
      ..sort((a, b) => _parseDate(b['date']?.toString()).compareTo(_parseDate(a['date']?.toString())));

    final areas = areasAsync.valueOrNull ?? [];

    if (tasksAsync.isLoading && allTasks.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final areaTabs = {
      ...areas.map((e) => e.name),
      ...allTasks.map((e) => e['area']?.toString() ?? '').where((e) => e.trim().isNotEmpty)
    }.toList()
      ..sort();
    final staffTabs = allTasks
        .map((task) => task['staffName']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final activeArea = _selectedArea ?? areaTabs.firstOrNull;
    final activeStaff = _selectedStaff ?? staffTabs.firstOrNull;

    final filtered = _filteredTasks(
      allTasks,
      mode: _mode,
      area: activeArea,
      staff: activeStaff,
      from: _dateFrom,
      to: _dateTo,
    );

    final totalPages = filtered.isEmpty ? 1 : ((filtered.length - 1) ~/ _pageSize) + 1;
    final safePage = _page.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final paged = filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                  onPressed: () => context.goNamed(RouteNames.supervisorHome),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.petugasProfile),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Icon(PhosphorIcons.user(), color: AppColors.textPrimary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Dashboard Supervisor',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          user.username,
                          style: AppTypography.h1.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 162,
                child: Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        icon: PhosphorIcons.mapPinArea(PhosphorIconsStyle.bold),
                        countText: '${areaTabs.length} Areas',
                        description: 'Patrol reports across all Aksama Adi Andana areas.',
                        isActive: _mode == _DashboardMode.area,
                        isStaffCard: false,
                        onTap: () => setState(() {
                          _mode = _DashboardMode.area;
                          _resetPage();
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
                        countText: '${staffTabs.length} HSE Staff',
                        description: 'HSE personnel who submit reports from each location.',
                        isActive: _mode == _DashboardMode.staff,
                        isStaffCard: true,
                        onTap: () => setState(() {
                          _mode = _DashboardMode.staff;
                          _resetPage();
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      _buildContextTabs(areaTabs: areaTabs, staffTabs: staffTabs, activeArea: activeArea, activeStaff: activeStaff),
                      const SizedBox(height: 12),
                      _buildDateFilters(context),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _mode == _DashboardMode.area
                            ? _buildAreaTable(paged)
                            : _buildStaffTable(paged),
                      ),
                      const SizedBox(height: 8),
                      _buildPagination(filtered.length, safePage, totalPages),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String countText,
    required String description,
    required bool isActive,
    required bool isStaffCard,
    required VoidCallback onTap,
  }) {
    final bool isStaffActive = isStaffCard && isActive;
    final Color accentColor = isStaffCard ? AppColors.primary : const Color(0xFFD4D8FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? accentColor : Colors.white.withValues(alpha: 0.08),
            width: isActive ? 1.2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF1E1E1E), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countText,
                    style: AppTypography.h3.copyWith(
                      color: isStaffActive ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.75), height: 1.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextTabs({
    required List<String> areaTabs,
    required List<String> staffTabs,
    required String? activeArea,
    required String? activeStaff,
  }) {
    final labels = _mode == _DashboardMode.area ? areaTabs : staffTabs;
    if (labels.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text('No tab data available.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final label = labels[index];
          final selected = _mode == _DashboardMode.area ? label == activeArea : label == activeStaff;

          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() {
              if (_mode == _DashboardMode.area) {
                _selectedArea = label;
              } else {
                _selectedStaff = label;
              }
              _resetPage();
            }),
            selectedColor: _mode == _DashboardMode.staff ? AppColors.primary : const Color(0xFFD4D8FF),
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            labelStyle: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF1E1E1E) : AppColors.textSecondary,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: labels.length,
      ),
    );
  }

  Widget _buildDateFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _dateButton(
            label: 'Date From',
            value: _dateFrom,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateFrom ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() {
                _dateFrom = DateTime(picked.year, picked.month, picked.day);
                if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
                  _dateTo = _dateFrom;
                }
                _resetPage();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _dateButton(
            label: 'Date To',
            value: _dateTo,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateTo ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() {
                _dateTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                _resetPage();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      icon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 16),
      label: Text(
        value == null ? label : DateFormat('dd MMM yyyy').format(value),
        style: AppTypography.caption.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildAreaTable(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return _emptyState();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.08)),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Task Name')),
            DataColumn(label: Text('Risk')),
            DataColumn(label: Text('Root Cause')),
            DataColumn(label: Text('Reported By')),
            DataColumn(label: Text('Date Created')),
          ],
          rows: rows.map((item) {
            return DataRow(cells: [
              DataCell(_statusCell(item['status']?.toString() ?? '-')),
              DataCell(SizedBox(width: 180, child: Text(_titleOf(item), overflow: TextOverflow.ellipsis))),
              DataCell(_riskDot(item['riskLevel']?.toString())),
              DataCell(SizedBox(width: 150, child: Text(item['rootCause']?.toString() ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(SizedBox(width: 130, child: Text(item['staffName']?.toString() ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(Text(_formatDate(item['date']?.toString()))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStaffTable(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return _emptyState();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.08)),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Area')),
            DataColumn(label: Text('Risk')),
            DataColumn(label: Text('Notes')),
            DataColumn(label: Text('Root Cause')),
            DataColumn(label: Text('Date Created')),
          ],
          rows: rows.map((item) {
            return DataRow(cells: [
              DataCell(_statusCell(item['status']?.toString() ?? '-')),
              DataCell(SizedBox(width: 170, child: Text(item['area']?.toString() ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(_riskDot(item['riskLevel']?.toString())),
              DataCell(SizedBox(width: 170, child: Text(item['notes']?.toString() ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(SizedBox(width: 150, child: Text(item['rootCause']?.toString() ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(Text(_formatDate(item['date']?.toString()))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _statusCell(String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 10, color: _statusColor(status)),
        const SizedBox(width: 6),
        Text(status),
      ],
    );
  }

  Widget _riskDot(String? level) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _riskColor(level),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'No reports found for selected filters.',
        style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildPagination(int totalItems, int page, int totalPages) {
    Widget pagerInfo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: page > 1 ? () => setState(() => _page = page - 1) : null,
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: Colors.white),
        ),
        Text(
          'Page $page of $totalPages',
          style: AppTypography.caption.copyWith(color: Colors.white),
        ),
        IconButton(
          onPressed: page < totalPages ? () => setState(() => _page = page + 1) : null,
          icon: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: Colors.white),
        ),
      ],
    );

    Widget pageSizeSelector = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _pageSize,
            dropdownColor: AppColors.surface,
            style: AppTypography.caption.copyWith(color: Colors.white),
            items: _pageSizes
                .map((size) => DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size items per page'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _pageSize = value;
                _resetPage();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$totalItems items',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pagerInfo,
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: pageSizeSelector,
              ),
            ],
          );
        }

        return Row(
          children: [
            pagerInfo,
            const Spacer(),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: pageSizeSelector,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _filteredTasks(
    List<Map<String, dynamic>> input, {
    required _DashboardMode mode,
    required String? area,
    required String? staff,
    required DateTime? from,
    required DateTime? to,
  }) {
    return input.where((task) {
      if (mode == _DashboardMode.area) {
        if (area != null && (task['area']?.toString() ?? '') != area) return false;
      } else {
        if (staff != null && (task['staffName']?.toString() ?? '') != staff) return false;
      }

      final dt = _parseDate(task['date']?.toString());
      if (from != null && dt.isBefore(from)) return false;
      if (to != null && dt.isAfter(to)) return false;
      return true;
    }).toList();
  }

  String _titleOf(Map<String, dynamic> task) {
    final title = task['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;
    final area = task['area']?.toString() ?? '-';
    final cause = task['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }

  DateTime _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(String? raw) {
    final dt = DateTime.tryParse(raw ?? '');
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  Color _statusColor(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD4D8FF);
      case 'follow up done':
        return const Color(0xFFFAFF9F);
      case 'completed':
        return const Color(0xFFC1F0D0);
      case 'canceled':
        return Colors.white;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _riskColor(String? riskLevel) {
    final value = (riskLevel ?? '').toLowerCase();

    if (value.contains('ringan') || value == '1') return AppColors.riskLevel1;
    if (value.contains('menengah') || value == '2') return AppColors.riskLevel2;
    if (value.contains('berat') || value == '3') return AppColors.riskLevel3;
    if (value.contains('kritis') || value == '4') return AppColors.riskLevel4;
    return AppColors.textSecondary;
  }

  void _resetPage() {
    _page = 1;
  }
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
