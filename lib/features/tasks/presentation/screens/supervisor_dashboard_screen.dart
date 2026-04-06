import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class SupervisorDashboardScreen extends ConsumerStatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  ConsumerState<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends ConsumerState<SupervisorDashboardScreen> {
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    // Default filter: 7 hari terakhir
    final now = DateTime.now();
    _dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _dateFrom = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(supervisorAllVisibleTaskMapsProvider);

    if (user == null || user.role != UserRole.hseSupervisor) {
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

    if (tasksAsync.isLoading && allTasks.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filter tasks berdasarkan tanggal
    final filteredTasks = _filterTasksByDate(allTasks);

    // Group tasks per hari untuk chart
    final dailyTaskData = _groupTasksByDay(filteredTasks);

    // Calculate stats
    final totalTasks = filteredTasks.length;
    final pendingTasks = filteredTasks.where((t) => _getActualStatus(t).toLowerCase() == 'pending').length;
    final pendingRejectedTasks = filteredTasks.where((t) => _getActualStatus(t).toLowerCase() == 'pending rejected').length;
    final completedTasks = filteredTasks.where((t) => _getActualStatus(t).toLowerCase() == 'completed').length;
    final followUpDoneTasks = filteredTasks.where((t) => _getActualStatus(t).toLowerCase() == 'follow up done').length;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 24, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                    onPressed: () => context.goNamed(RouteNames.supervisorHome),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dashboard',
                    style: AppTypography.h1.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Cards Row 1
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _statCard('Total Tasks', '$totalTasks', AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Pending', '$pendingTasks', const Color(0xFFD4D8FF))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Pending Rejected', '$pendingRejectedTasks', const Color(0xFFFFB3BA))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Stats Cards Row 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _statCard('Completed', '$completedTasks', const Color(0xFFC1F0D0))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Follow Up Done', '$followUpDoneTasks', const Color(0xFFFAFF9F))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Avg per Day', '${totalTasks > 0 ? (totalTasks / 7).toStringAsFixed(1) : '0'}', AppColors.secondary)),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                      _buildDateFilters(context),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildBarChart(dailyTaskData),
                      ),
                      const SizedBox(height: 8),
                      _buildLegend(),
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

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
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

              final newFrom = DateTime(picked.year, picked.month, picked.day);
              // Max 7 days constraint
              if (_dateTo != null) {
                final maxFrom = _dateTo!.subtract(const Duration(days: 6));
                if (newFrom.isBefore(maxFrom)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maksimal filter adalah 7 hari')),
                    );
                  }
                  return;
                }
              }

              setState(() {
                _dateFrom = newFrom;
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

              final newTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
              // Max 7 days constraint
              if (_dateFrom != null) {
                final maxTo = _dateFrom!.add(const Duration(days: 6));
                if (newTo.isAfter(maxTo)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maksimal filter adalah 7 hari')),
                    );
                  }
                  return;
                }
              }

              setState(() {
                _dateTo = newTo;
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

  Widget _buildBarChart(Map<String, int> dailyData) {
    if (dailyData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    // Sort keys by date
    final sortedDates = dailyData.keys.toList()
      ..sort((a, b) => DateFormat('dd MMM yyyy').parse(a).compareTo(DateFormat('dd MMM yyyy').parse(b)));

    // Find max value for Y-axis scaling
    final maxValue = dailyData.values.fold(0, (max, value) => value > max ? value : max);
    final yMax = maxValue > 0 ? ((maxValue / 5).ceil() * 5) : 10;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yMax.toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => const Color(0xFF1E1E1E).withValues(alpha: 0.95),
              tooltipPadding: const EdgeInsets.all(12),
              tooltipMargin: 12,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = sortedDates[groupIndex.toInt()];
                final value = rod.toY.toInt();
                return BarTooltipItem(
                  '$date\n',
                  TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '$value',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedDates.length) return const Text('');
                  final date = sortedDates[index];
                  final parts = date.split(' ');
                  if (parts.length >= 2) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        parts[0], // Only show day
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    );
                  }
                  return Text(
                    date,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Hide max value label for cleaner look
                  if (value == meta.max) return const SizedBox.shrink();

                  // Hide values that are too high or out of range
                  if (value > yMax) return const SizedBox.shrink();

                  final intValue = value.toInt();

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      intValue.toString(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 40,
                interval: yMax > 20 ? (yMax / 5).ceilToDouble() : (yMax / 5).ceilToDouble() > 0 ? (yMax / 5).ceilToDouble() : 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.primary.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [5, 5], // Dashed lines for better visual
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            sortedDates.length,
            (index) {
              final date = sortedDates[index];
              final value = dailyData[date]?.toDouble() ?? 0;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    width: 24,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                        const Color(0xFF5E5CE6),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  const Color(0xFF5E5CE6),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Total Tasks per Day',
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menentukan status sebenarnya dari task
  String _getActualStatus(Map<String, dynamic> task) {
    // Cek follow-ups terakhir
    final followUps = task['followUps'] as List<dynamic>? ??
                      task['follow_ups'] as List<dynamic>? ?? [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = lastFollowUp['status']?.toString().toLowerCase();

      // Jika follow-up terakhir rejected, maka status task adalah "Pending Rejected"
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }

      // Jika follow-up terakhir approved, maka status task adalah "Follow Up Done"
      if (lastStatus == 'approved') {
        return 'Follow Up Done';
      }
    }

    // Default ke status task
    final status = task['status']?.toString() ?? 'Pending';
    return status;
  }

  List<Map<String, dynamic>> _filterTasksByDate(List<Map<String, dynamic>> tasks) {
    if (_dateFrom == null || _dateTo == null) return tasks;

    return tasks.where((task) {
      final taskDate = _parseDate(task['date']?.toString());
      return !taskDate.isBefore(_dateFrom!) && !taskDate.isAfter(_dateTo!);
    }).toList();
  }

  Map<String, int> _groupTasksByDay(List<Map<String, dynamic>> tasks) {
    final Map<String, int> grouped = {};

    // Initialize all dates in range with 0
    if (_dateFrom != null && _dateTo != null) {
      var current = DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day);
      final end = DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day);

      while (current.isBefore(end.add(const Duration(days: 1)))) {
        final key = DateFormat('dd MMM yyyy').format(current);
        grouped[key] = 0;
        current = current.add(const Duration(days: 1));
      }
    }

    // Count tasks per day
    for (final task in tasks) {
      final taskDate = _parseDate(task['date']?.toString());
      // Normalize to date only (remove time component)
      final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final key = DateFormat('dd MMM yyyy').format(normalizedDate);
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped;
  }

  DateTime _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.fromMillisecondsSinceEpoch(0);

    // Convert to local time consistently
    return parsed.toLocal();
  }

  String _formatDate(String? raw) {
    final dt = DateTime.tryParse(raw ?? '');
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }
}
