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
import '../providers/task_provider.dart';

class SupervisorAllTasksScreen extends ConsumerStatefulWidget {
  const SupervisorAllTasksScreen({super.key});

  @override
  ConsumerState<SupervisorAllTasksScreen> createState() => _SupervisorAllTasksScreenState();
}

class _SupervisorAllTasksScreenState extends ConsumerState<SupervisorAllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _searchQuery = '';
  String _scope = 'own';
  String? _selectedStaffName;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ownAsync = ref.watch(supervisorOwnTaskMapsProvider);
    final staffAsync = ref.watch(supervisorStaffTaskMapsProvider);
    final staffNamesAsync = ref.watch(supervisorStaffNamesProvider);

    if (user == null || user.role != 'supervisor') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goNamed(RouteNames.login);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ownTasks = ownAsync.valueOrNull ?? <Map<String, dynamic>>[];
    final staffTasks = staffAsync.valueOrNull ?? <Map<String, dynamic>>[];
    final staffNames = staffNamesAsync.valueOrNull ?? <String>[];

    final selectedStaff = _selectedStaffName ?? staffNames.firstOrNull;
    final sourceList = _scope == 'own'
        ? ownTasks
        : selectedStaff == null
            ? <Map<String, dynamic>>[]
            : staffTasks.where((e) => (e['staffName']?.toString() ?? '') == selectedStaff).toList();

    if ((_scope == 'staff') && _selectedStaffName == null && staffNames.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedStaffName = staffNames.first);
        }
      });
    }

    if ((_scope == 'own' && ownAsync.isLoading && ownTasks.isEmpty) ||
        (_scope == 'staff' && staffAsync.isLoading && sourceList.isEmpty)) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),

              // Compact Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Supervisor Tasks', style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 8),

              // Date Filter & Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Date Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: _dateFilterButton(
                            label: 'From',
                            date: _dateFrom,
                            onTap: () => _selectDateFrom(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _dateFilterButton(
                            label: 'To',
                            date: _dateTo,
                            onTap: () => _selectDateTo(context),
                          ),
                        ),
                        if (_dateFrom != null || _dateTo != null)
                          IconButton(
                            icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 20),
                            onPressed: () => setState(() {
                              _dateFrom = null;
                              _dateTo = null;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                        prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.textSecondary, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildScopeTabs(),
              if (_scope == 'staff') ...[
                const SizedBox(height: 8),
                _buildStaffSelector(staffNames),
              ],
              const SizedBox(height: 12),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                indicator: BoxDecoration(
                  color: _scope == 'staff' ? AppColors.primary : const Color(0xFFD4D8FF),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                labelColor: const Color(0xFF1E1E1E),
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  _buildTab('All'),
                  _buildTab('Pending'),
                  _buildTab('Follow Up Done'),
                  _buildTab('Pending Rejected'),
                  _buildTab('Completed'),
                  _buildTab('Canceled'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTaskList(sourceList, 'All'),
                    _buildTaskList(sourceList, 'Pending'),
                    _buildTaskList(sourceList, 'Follow Up Done'),
                    _buildTaskList(sourceList, 'Pending Rejected'),
                    _buildTaskList(sourceList, 'Completed'),
                    _buildTaskList(sourceList, 'Canceled'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(height: 36, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(text, style: TextStyle(fontSize: 13))));
  }

  Widget _dateFilterButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 16, color: AppColors.textSecondary),
      label: Text(
        date == null ? label : DateFormat('dd MMM').format(date),
        style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = DateTime(picked.year, picked.month, picked.day);
        if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
          _dateTo = _dateFrom;
        }
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  Widget _buildScopeTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Expanded(
              child: _scopeTabButton(
                label: 'Own Task',
                selected: _scope == 'own',
                onTap: () => setState(() => _scope = 'own'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _scopeTabButton(
                label: 'Staff Task',
                selected: _scope == 'staff',
                onTap: () => setState(() => _scope = 'staff'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeTabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color selectedColor = _scope == 'staff' ? AppColors.primary : const Color(0xFFD4D8FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body1.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? const Color(0xFF1E1E1E) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffSelector(List<String> staffNames) {
    if (staffNames.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text('Belum ada data staff.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: staffNames.map((name) {
          final isSelected = (_selectedStaffName ?? staffNames.firstOrNull) == name;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _chip(name, isSelected, () => setState(() => _selectedStaffName = name)),
          );
        }).toList(),
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    final Color selectedColor = _scope == 'staff' ? AppColors.primary : const Color(0xFFD4D8FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          text,
          style: AppTypography.body1.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xFF1E1E1E) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // Helper untuk menentukan status sebenarnya dari report
  String _getActualStatus(Map<String, dynamic> report) {
    // Cek follow-ups terakhir
    final followUps = report['followUps'] as List<dynamic>? ??
                      report['follow_ups'] as List<dynamic>? ?? [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = lastFollowUp['status']?.toString().toLowerCase();

      // Jika follow-up terakhir rejected, maka status report adalah "Pending Rejected"
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }
    }

    // Default ke status report
    return report['status']?.toString() ?? 'Pending';
  }

  Widget _buildTaskList(List<Map<String, dynamic>> source, String filter) {
    var filtered = filter == 'All' ? source : source.where((r) => _getActualStatus(r) == filter).toList();

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        final title = _getReportTitle(r).toLowerCase();
        final area = (r['area']?.toString() ?? '').toLowerCase();
        return title.contains(query) || area.contains(query);
      }).toList();
    }

    // Filter berdasarkan tanggal
    if (_dateFrom != null || _dateTo != null) {
      filtered = filtered.where((r) {
        final dateStr = r['date']?.toString();
        if (dateStr == null || dateStr.isEmpty) return false;
        try {
          final date = DateTime.parse(dateStr);
          if (_dateFrom != null && date.isBefore(_dateFrom!)) return false;
          if (_dateTo != null && date.isAfter(_dateTo!)) return false;
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin), size: 48, color: AppColors.surfaceLight),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ? 'No tasks found for "$_searchQuery"' : 'No $filter tasks yet.',
              style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final task in filtered) {
      final area = task['area']?.toString() ?? 'Unknown Area';
      grouped.putIfAbsent(area, () => []);
      grouped[area]!.add(task);
    }

    final sortedAreas = grouped.keys.toList()..sort();

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: sortedAreas.length,
      itemBuilder: (context, index) {
        final area = sortedAreas[index];
        final tasks = grouped[area]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('${index + 1}. $area', style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontSize: 14)),
            ),
            ...tasks.asMap().entries.map((entry) {
              final task = entry.value;
              final actualStatus = _getActualStatus(task);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildExactTaskCard(
                  context,
                  title: _getReportTitle(task),
                  dateString: task['date']?.toString(),
                  rawStatus: actualStatus,
                  tag: _getStatusTag(actualStatus),
                  reportId: task['id'].toString(),
                  staffName: task['staffName']?.toString() ?? '-',
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD4D8FF);
      case 'follow up done':
        return const Color(0xFFFAFF9F);
      case 'pending rejected':
        return const Color(0xFFFFCDD2); // Merah muda
      case 'completed':
        return const Color(0xFFC1F0D0);
      case 'canceled':
        return const Color(0xFF1E1E1E);
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String? dateString,
    required String rawStatus,
    required String reportId,
    required String staffName,
    String? tag,
  }) {
    final bool isDark = rawStatus.toLowerCase() == 'canceled';
    final Color bgColor = _getColorByStatus(rawStatus);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final Color stripeColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardStripedPainter(color: stripeColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.body1.copyWith(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.caption.copyWith(color: isDark ? Colors.white : const Color(0xFF6B6E94), fontWeight: FontWeight.w600, fontSize: 9),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          staffName,
                          style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatIndonesianDate(dateString),
                          style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(dateString),
                        style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatIndonesianDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  String? _getStatusTag(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'follow up done':
        return 'Waiting Review';
      case 'pending rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      default:
        return null;
    }
  }

  String _getReportTitle(Map<String, dynamic> report) {
    final title = report['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;

    final area = report['area']?.toString() ?? '-';
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }
}

class _CardStripedPainter extends CustomPainter {
  final Color color;
  _CardStripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const double space = 8.0;
    for (double i = -size.height; i < size.width; i += space) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension _ListFirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
