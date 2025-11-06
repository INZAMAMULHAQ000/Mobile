import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/apartments/apartment_list_screen.dart';
import '../../screens/apartments/apartment_detail_screen.dart';
import '../../screens/guests/guest_list_screen.dart';
import '../../screens/guests/guest_detail_screen.dart';
import '../../screens/finances/finance_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../services/auth_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authService.currentUser != null;

      if (!isAuthenticated && !state.location.startsWith('/auth')) {
        return AppRoutes.login;
      }

      if (isAuthenticated && state.location.startsWith('/auth')) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),

          // Apartment Routes
          GoRoute(
            path: AppRoutes.apartments,
            name: AppRoutes.apartments,
            builder: (context, state) => const ApartmentListScreen(),
            routes: [
              GoRoute(
                path: '/:apartmentId',
                name: 'apartmentDetail',
                builder: (context, state) {
                  final apartmentId = state.pathParameters['apartmentId']!;
                  return ApartmentDetailScreen(apartmentId: apartmentId);
                },
              ),
            ],
          ),

          // Guest Routes
          GoRoute(
            path: AppRoutes.guests,
            name: AppRoutes.guests,
            builder: (context, state) => const GuestListScreen(),
            routes: [
              GoRoute(
                path: '/:guestId',
                name: 'guestDetail',
                builder: (context, state) {
                  final guestId = state.pathParameters['guestId']!;
                  return GuestDetailScreen(guestId: guestId);
                },
              ),
            ],
          ),

          // Finance Route
          GoRoute(
            path: AppRoutes.finance,
            name: AppRoutes.finance,
            builder: (context, state) => const FinanceScreen(),
          ),

          // Reports Route
          GoRoute(
            path: AppRoutes.reports,
            name: AppRoutes.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.apartment_outlined),
      selectedIcon: Icon(Icons.apartment),
      label: 'Apartments',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Guests',
    ),
    const NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Finance',
    ),
    const NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Reports',
    ),
  ];

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.apartments);
        break;
      case 2:
        context.go(AppRoutes.guests);
        break;
      case 3:
        context.go(AppRoutes.finance);
        break;
      case 4:
        context.go(AppRoutes.reports);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).location;

    // Update selected index based on current route
    if (location.startsWith(AppRoutes.dashboard)) {
      _selectedIndex = 0;
    } else if (location.startsWith(AppRoutes.apartments)) {
      _selectedIndex = 1;
    } else if (location.startsWith(AppRoutes.guests)) {
      _selectedIndex = 2;
    } else if (location.startsWith(AppRoutes.finance)) {
      _selectedIndex = 3;
    } else if (location.startsWith(AppRoutes.reports)) {
      _selectedIndex = 4;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}