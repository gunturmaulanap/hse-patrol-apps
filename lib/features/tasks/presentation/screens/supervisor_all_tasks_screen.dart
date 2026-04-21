import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer/base_shimmer.dart';
import '../../../../core/widgets/shimmer/shimmer_box.dart';
import '../../../../core/utils/progressive_pagination.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/hse_staff_model.dart';
import '../providers/task_provider.dart';

class SupervisorAllTasksScreen extends ConsumerStatefulWidget {
  const SupervisorAllTasksScreen({super.key});

  @override
  ConsumerState<SupervisorAllTasksScreen> createState() =>
      _SupervisorAllTasksScreenState();
}

class _SupervisorAllTasksScreenState
    extends ConsumerState<SupervisorAllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _searchQuery = '';
  String _scope = 'own';
  int? _selectedStaffId;
  final Map<String, int> _visibleCountPerArea = {};
  String _lastFilterSignature = '';

  void _resetPagination() {
    _visibleCountPerArea.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(supervisorOwnTaskMapsProvider);
      ref.invalidate(supervisorStaffTaskMapsProvider);
      ref.invalidate(staffListProvider);
      ref.read(tasksFutureProvider.future);
      ref.read(petugasTaskMapsProvider.future);
      ref.read(supervisorOwnTaskMapsProvider.future);
      ref.read(supervisorStaffTaskMapsProvider.future);
      ref.read(staffListProvider.future);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    debugPrint('[SupervisorAllTasksScreen] pull-to-refresh triggered');
    ref.invalidate(tasksFutureProvider);
    ref.invalidate(petugasTaskMapsProvider);
    ref.invalidate(supervisorOwnTaskMapsProvider);
    ref.invalidate(supervisorStaffTaskMapsProvider);
    ref.invalidate(staffListProvider);
    final results = await Future.wait([
      ref.read(tasksFutureProvider.future),
      ref.read(petugasTaskMapsProvider.future),
      ref.read(supervisorOwnTaskMapsProvider.future),
      ref.read(supervisorStaffTaskMapsProvider.future),
      ref.read(staffListProvider.future),
    ]);

    final totalTasks = (results[0] as List).length;
    final totalPetugasMaps = (results[1] as List).length;
    final totalOwn = (results[2] as List).length;
    final totalStaff = (results[3] as List).length;
    final totalStaffList = (results[4] as List).length;

    debugPrint(
      '[SupervisorAllTasksScreen] refresh complete -> tasks=$totalTasks maps=$totalPetugasMaps own=$totalOwn staff=$totalStaff staffs=$totalStaffList',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ownAsync = ref.watch(supervisorOwnTaskMapsProvider);
    final staffAsync = ref.watch(supervisorStaffTaskMapsProvider);
    final staffListAsync = ref.watch(staffListProvider);

    if (user == null || user.role != UserRole.hseSupervisor) {
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
    final staffList = staffListAsync.valueOrNull ?? <HseStaffModel>[];

    final filterSignature =
        'scope=$_scope|staff=${_selectedStaffId ?? '-'}|q=${_searchQuery.trim()}|from=${_dateFrom?.toIso8601String() ?? '-'}|to=${_dateTo?.toIso8601String() ?? '-'}';
    if (_lastFilterSignature != filterSignature) {
      _lastFilterSignature = filterSignature;
      _resetPagination();
    }

    // Build staff entries dari API staff list
    final staffEntries = staffList
        .map((staff) => _StaffEntry(id: staff.id, name: staff.name))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final selectedStaffId = _selectedStaffId ?? staffEntries.firstOrNull?.id;
    final sourceList = _scope == 'own'
        ? ownTasks
        : selectedStaffId == null
            ? <Map<String, dynamic>>[]
            : staffTasks
                .where((e) => _taskOwnerId(e) == selectedStaffId)
                .toList();

    debugPrint(
      '[SupervisorAllTasksScreen] scope=$_scope source=${sourceList.length} '
      'dateBuckets=${_buildDateBuckets(sourceList)}',
    );

    if ((_scope == 'staff') &&
        _selectedStaffId == null &&
        staffEntries.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedStaffId = staffEntries.first.id;
            _resetPagination();
          });
        }
      });
    }

    final isInitialOwnLoading = _scope == 'own' &&
        ((ownAsync.isLoading && !ownAsync.hasValue) || !ownAsync.hasValue);
    final isInitialStaffLoading = _scope == 'staff' &&
        ((staffAsync.isLoading && !staffAsync.hasValue) ||
            (staffListAsync.isLoading && !staffListAsync.hasValue) ||
            !staffAsync.hasValue ||
            !staffListAsync.hasValue);

    final isTransitionOwnLoading =
        _scope == 'own' && ownAsync.isLoading && sourceList.isEmpty;
    final isTransitionStaffLoading = _scope == 'staff' &&
        (staffAsync.isLoading || staffListAsync.isLoading) &&
        sourceList.isEmpty;

    if (isInitialOwnLoading ||
        isInitialStaffLoading ||
        isTransitionOwnLoading ||
        isTransitionStaffLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: _TaskListShimmer(),
      );
    }

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Supervisor Tasks',
                        style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
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
                            icon: Icon(
                                PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                                size: 20),
                            onPressed: () => setState(() {
                              _dateFrom = null;
                              _dateTo = null;
                              _resetPagination();
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: AppTypography.body1
                          .copyWith(color: AppColors.textPrimary),
                      onChanged: (value) => setState(() {
                        _searchQuery = value;
                        _resetPagination();
                      }),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AppTypography.body1
                            .copyWith(color: AppColors.textSecondary),
                        prefixIcon: Icon(PhosphorIcons.magnifyingGlass(),
                            color: AppColors.textSecondary, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                    PhosphorIcons.xCircle(
                                        PhosphorIconsStyle.fill),
                                    color: AppColors.textSecondary,
                                    size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _resetPagination();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
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
                _buildStaffSelector(staffEntries),
              ],
              const SizedBox(height: 12),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                indicator: BoxDecoration(
                  color: _scope == 'staff'
                      ? AppColors.primary
                      : const Color(0xFFD4D8FF),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                labelColor: const Color(0xFF1E1E1E),
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle:
                    AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
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
    return Tab(
        height: 36,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(text, style: TextStyle(fontSize: 13))));
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
      icon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
          size: 16, color: AppColors.textSecondary),
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
        _resetPagination();
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
        _resetPagination();
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
                onTap: () => setState(() {
                  _scope = 'own';
                  _resetPagination();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _scopeTabButton(
                label: 'Staff Task',
                selected: _scope == 'staff',
                onTap: () => setState(() {
                  _scope = 'staff';
                  _resetPagination();
                }),
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
    final Color selectedColor =
        _scope == 'staff' ? AppColors.primary : const Color(0xFFD4D8FF);

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
              color:
                  selected ? const Color(0xFF1E1E1E) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffSelector(List<_StaffEntry> staffEntries) {
    if (staffEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text('Belum ada data staff.',
            style:
                AppTypography.body1.copyWith(color: AppColors.textSecondary)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: staffEntries.map((entry) {
          final selectedId = _selectedStaffId ?? staffEntries.firstOrNull?.id;
          final isSelected = selectedId == entry.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _chip(entry.name, isSelected,
                () => setState(() {
                      _selectedStaffId = entry.id;
                      _resetPagination();
                    })),
          );
        }).toList(),
      ),
    );
  }

  int _taskOwnerId(Map<String, dynamic> task) {
    final raw = task['created_by'] ??
        task['createdBy'] ??
        task['userId'] ??
        task['user_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Map<String, int> _buildDateBuckets(List<Map<String, dynamic>> reports,
      {int maxBuckets = 10}) {
    final buckets = <String, int>{};
    for (final report in reports) {
      final key = _dateKey(report['date']);
      buckets[key] = (buckets[key] ?? 0) + 1;
    }
    final sorted = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    return {
      for (final key in sorted.take(maxBuckets)) key: buckets[key] ?? 0,
    };
  }

  String _dateKey(dynamic rawDate) {
    final parsed = DateTime.tryParse(rawDate?.toString() ?? '');
    if (parsed == null) return 'invalid';
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    final Color selectedColor =
        _scope == 'staff' ? AppColors.primary : const Color(0xFFD4D8FF);

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
        report['follow_ups'] as List<dynamic>? ??
        [];

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
    var filtered = filter == 'All'
        ? source
        : source.where((r) => _getActualStatus(r) == filter).toList();

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
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin),
                        size: 48, color: AppColors.surfaceLight),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No tasks found for "$_searchQuery"'
                          : 'No $filter tasks yet.',
                      style:
                          AppTypography.body1.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
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

    final List<Widget> listItems = [];

    for (int i = 0; i < sortedAreas.length; i++) {
        final area = sortedAreas[i];
        final tasks = grouped[area]!;
        final areaPaginationKey = '$filter::$area';

        final visibleCount = _visibleCountPerArea[areaPaginationKey] ?? ProgressivePagination.getNextVisibleCount(0);
        final hasMore = ProgressivePagination.hasMore(visibleCount, tasks.length);
        final visibleTasks = tasks.take(visibleCount).toList();

        // 1. Area Header
        listItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${i + 1}. $area',
                style: AppTypography.h3
                    .copyWith(color: AppColors.textPrimary, fontSize: 14)),
          )
        );

        // 2. Tasks
        for (final entry in visibleTasks.asMap().entries) {
          final task = entry.value;
          final actualStatus = _getActualStatus(task);
          listItems.add(
            Padding(
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
            )
          );
        }

        // 3. Load More / Footer Spacer
        if (hasMore) {
          final nextCount = ProgressivePagination.getNextVisibleCount(visibleCount);
          listItems.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: () {
                   setState(() {
                     _visibleCountPerArea[areaPaginationKey] = nextCount;
                   });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                ),
                child: Text(
                  ProgressivePagination.getButtonText(visibleCount, tasks.length),
                  style: AppTypography.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            )
          );
        } else {
          listItems.add(const SizedBox(height: 12));
        }
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        key: PageStorageKey<String>('supervisor_all_$filter'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: listItems.length,
        itemBuilder: (context, index) => listItems[index],
      ),
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
    final Color stripeColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context
          .pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
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
              child:
                  CustomPaint(painter: _CardStripedPainter(color: stripeColor)),
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
                          style: AppTypography.body1.copyWith(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF6B6E94),
                                fontWeight: FontWeight.w600,
                                fontSize: 9),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_scope == 'staff') ...[
                        Icon(PhosphorIcons.user(PhosphorIconsStyle.bold),
                            size: 13, color: textColor.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            staffName,
                            style: AppTypography.caption.copyWith(
                                color: textColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                                PhosphorIcons.calendarBlank(
                                    PhosphorIconsStyle.bold),
                                size: 13,
                                color: textColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatIndonesianDate(dateString),
                                style: AppTypography.caption.copyWith(
                                    color: textColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold),
                          size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(dateString),
                        style: AppTypography.caption.copyWith(
                            color: textColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 11),
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
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
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
      canvas.drawLine(
          Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StaffEntry {
  final int id;
  final String name;

  const _StaffEntry({required this.id, required this.name});
}

extension _ListFirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _TaskListShimmer extends StatelessWidget {
  const _TaskListShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: BaseShimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 200, height: 28),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 300, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BaseShimmer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 80, height: 24),
                        SizedBox(height: 12),
                        ShimmerBox(width: double.infinity, height: 20),
                        SizedBox(height: 8),
                        ShimmerBox(width: 150, height: 16),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ShimmerBox(width: 60, height: 14),
                            Spacer(),
                            ShimmerBox(width: 60, height: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
}
