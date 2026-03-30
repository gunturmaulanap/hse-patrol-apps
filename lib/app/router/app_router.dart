import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/shell/presentation/screens/petugas_shell_screen.dart';
import '../../features/shell/presentation/screens/pic_shell_screen.dart';
import '../../features/reports/presentation/screens/patrol_list_screen.dart';
import '../../features/reports/presentation/screens/petugas_home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/pic/presentation/screens/pic_home_screen.dart';
import '../../features/pic/presentation/screens/pic_finding_screen.dart';
import '../../features/reports/presentation/screens/create_report_building_type_screen.dart';
import '../../features/reports/presentation/screens/create_report_location_screen.dart';
import '../../features/reports/presentation/screens/create_report_risk_level_screen.dart';
import '../../features/reports/presentation/screens/create_report_photos_screen.dart';
import '../../features/reports/presentation/screens/create_report_notes_screen.dart';
import '../../features/reports/presentation/screens/create_report_root_cause_screen.dart';
import '../../features/reports/presentation/screens/create_report_review_screen.dart';
import '../../features/reports/presentation/screens/report_detail_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_photos_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_notes_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_review_screen.dart';
import '../../features/reports/presentation/screens/petugas_all_tasks_screen.dart';
import '../../features/reports/presentation/screens/petugas_calendar_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/petugas/calendar',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/report/:id',
        name: RouteNames.reportDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportDetailScreen(reportId: id);
        },
      ),
      GoRoute(
        path: '/pic/follow-up/photos',
        name: RouteNames.picFollowUpPhotos,
        builder: (context, state) => const PicFollowUpPhotosScreen(),
      ),
      GoRoute(
        path: '/pic/follow-up/notes',
        name: RouteNames.picFollowUpNotes,
        builder: (context, state) => const PicFollowUpNotesScreen(),
      ),
      GoRoute(
        path: '/pic/follow-up/review',
        name: RouteNames.picFollowUpReview,
        builder: (context, state) => const PicFollowUpReviewScreen(),
      ),

      GoRoute(
        path: '/petugas/create-report',
        name: RouteNames.petugasCreateReport,
        builder: (context, state) => const CreateReportBuildingTypeScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/location',
        name: RouteNames.petugasCreateReportLocation,
        builder: (context, state) => const CreateReportLocationScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/risk',
        name: RouteNames.petugasCreateReportRisk,
        builder: (context, state) => const CreateReportRiskLevelScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/photos',
        name: RouteNames.petugasCreateReportPhotos,
        builder: (context, state) => const CreateReportPhotosScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/notes',
        name: RouteNames.petugasCreateReportNotes,
        builder: (context, state) => const CreateReportNotesScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/root-cause',
        name: RouteNames.petugasCreateReportRootCause,
        builder: (context, state) => const CreateReportRootCauseScreen(),
      ),
      GoRoute(
        path: '/petugas/create-report/review',
        name: RouteNames.petugasCreateReportReview,
        builder: (context, state) => const CreateReportReviewScreen(),
      ),
      GoRoute(
        path: '/petugas/all-tasks',
        name: RouteNames.petugasAllTasks,
        builder: (context, state) => const PetugasAllTasksScreen(),
      ),

      // Petugas Routes (Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PetugasShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/petugas/calendar',
                name: RouteNames.petugasCalendar,
                builder: (context, state) => const PetugasCalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/petugas/home',
                name: RouteNames.petugasHome,
                builder: (context, state) => const PetugasHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/petugas/profile',
                name: RouteNames.petugasProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // PIC Routes (Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PicShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pic/home',
                name: RouteNames.picHome,
                builder: (context, state) => const PicHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pic/finding',
                name: RouteNames.picFinding,
                builder: (context, state) => const PicFindingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pic/profile',
                name: RouteNames.picProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});