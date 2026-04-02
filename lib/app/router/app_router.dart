import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/shell/presentation/screens/petugas_shell_screen.dart';
import '../../features/shell/presentation/screens/pic_shell_screen.dart';
import '../../features/shell/presentation/screens/supervisor_shell_screen.dart';
import '../../features/tasks/presentation/screens/petugas_home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/pic/presentation/screens/pic_home_screen.dart';
import '../../features/pic/presentation/screens/pic_finding_screen.dart';
import '../../features/pic/presentation/screens/pic_all_tasks_screen.dart';
import '../../features/pic/presentation/screens/pic_pending_tasks_screen.dart';
import '../../features/tasks/presentation/screens/create_task_building_type_screen.dart';
import '../../features/tasks/presentation/screens/create_task_location_screen.dart';
import '../../features/tasks/presentation/screens/create_task_risk_level_screen.dart';
import '../../features/tasks/presentation/screens/create_task_photos_screen.dart';
import '../../features/tasks/presentation/screens/create_task_notes_screen.dart';
import '../../features/tasks/presentation/screens/create_task_root_cause_screen.dart';
import '../../features/tasks/presentation/screens/create_task_review_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_photos_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_notes_screen.dart';
import '../../features/pic/presentation/screens/pic_follow_up_review_screen.dart';
import '../../features/tasks/presentation/screens/petugas_all_tasks_screen.dart';
import '../../features/tasks/presentation/screens/petugas_calendar_screen.dart';
import '../../features/tasks/presentation/screens/supervisor_home_screen.dart';
import '../../features/tasks/presentation/screens/supervisor_calendar_screen.dart';
import '../../features/tasks/presentation/screens/supervisor_all_tasks_screen.dart';
import '../../features/tasks/presentation/screens/supervisor_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/task/:id',
        name: RouteNames.taskDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: id);
        },
      ),
      // Deep Link Route untuk WhatsApp PIC Token
      GoRoute(
        path: '/api/hse/reports/pic/:picToken',
        builder: (context, state) {
          final picToken = state.pathParameters['picToken']!;

          // Cek apakah user sudah login
          // Jika belum login, bisa redirect ke login atau simpan token untuk diproses setelah login
          // Untuk sekarang, kita redirect langsung ke task detail dengan picToken sebagai parameter

          return TaskDetailScreen(taskId: picToken, picToken: picToken);
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
        path: '/petugas/create-task',
        name: RouteNames.petugasCreateTask,
        builder: (context, state) => const CreateTaskBuildingTypeScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/location',
        name: RouteNames.petugasCreateTaskLocation,
        builder: (context, state) => const CreateTaskLocationScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/risk',
        name: RouteNames.petugasCreateTaskRisk,
        builder: (context, state) => const CreateTaskRiskLevelScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/photos',
        name: RouteNames.petugasCreateTaskPhotos,
        builder: (context, state) => const CreateTaskPhotosScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/notes',
        name: RouteNames.petugasCreateTaskNotes,
        builder: (context, state) => const CreateTaskNotesScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/root-cause',
        name: RouteNames.petugasCreateTaskRootCause,
        builder: (context, state) => const CreateTaskRootCauseScreen(),
      ),
      GoRoute(
        path: '/petugas/create-task/review',
        name: RouteNames.petugasCreateTaskReview,
        builder: (context, state) => const CreateTaskReviewScreen(),
      ),
      GoRoute(
        path: '/petugas/all-tasks',
        name: RouteNames.petugasAllTasks,
        builder: (context, state) => const PetugasAllTasksScreen(),
      ),
      GoRoute(
        path: '/supervisor/all-tasks',
        name: RouteNames.supervisorAllTasks,
        builder: (context, state) => const SupervisorAllTasksScreen(),
      ),
      GoRoute(
        path: '/supervisor/dashboard',
        name: RouteNames.supervisorDashboard,
        builder: (context, state) => const SupervisorDashboardScreen(),
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
        ],
      ),

      // Petugas Additional Routes (Profile, Tasks, Create - accessed via push, outside shell)
      GoRoute(
        path: '/petugas/profile',
        name: RouteNames.petugasProfile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Supervisor Routes (Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SupervisorShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/supervisor/calendar',
                name: RouteNames.supervisorCalendar,
                builder: (context, state) => const SupervisorCalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/supervisor/home',
                name: RouteNames.supervisorHome,
                builder: (context, state) => const SupervisorHomeScreen(),
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
                path: '/pic/tasks',
                name: RouteNames.picTasks,
                builder: (context, state) => const PicAllTasksScreen(),
              ),
            ],
          ),
        ],
      ),

      // Additional PIC Routes (Finding & Profile - accessed via push)
      GoRoute(
        path: '/pic/finding',
        name: RouteNames.picFinding,
        builder: (context, state) => const PicFindingScreen(),
      ),
      GoRoute(
        path: '/pic/pending-tasks',
        name: RouteNames.picCreateTask,
        builder: (context, state) => const PicPendingTasksScreen(),
      ),
      GoRoute(
        path: '/pic/profile',
        name: RouteNames.picProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
