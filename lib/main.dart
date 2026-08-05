import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'repositories/auth_repository.dart';
import 'core/router/app_routes.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/design_tokens.dart';
import 'widgets/app_hover_lift.dart';
import 'screens/auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AutoMarketApp(),
    ),
  );
}

class AutoMarketApp extends StatelessWidget {
  const AutoMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Market Global',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      locale: context.watch<LanguageService>().locale,
      themeMode: context.watch<LanguageService>().themeMode,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('tj'),
        Locale('uz'),
        Locale('zh'),
        Locale('ky'),
        Locale('kk'),
        Locale('ar'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isCheckingAuth) {
            return const _PremiumSplashScreen();
          }

          if (authProvider.isAuthenticated) {
            if (!authProvider.isEmailVerified) {
              return const EmailVerificationScreen();
            }
            return const MainShell();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}

class _PremiumSplashScreen extends StatefulWidget {
  const _PremiumSplashScreen();

  @override
  State<_PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<_PremiumSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.accent.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.58, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Auto Market Global',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 18),
                const SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _closeAddMenuAndOpen(BuildContext sheetContext, String route) {
    Navigator.of(sheetContext).pop();
    if (!mounted) return;
    Navigator.of(context).pushNamed(route);
  }

  void _openAddMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.translate('whatToDo'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _AddMenuTile(
                  icon: Icons.directions_car,
                  title: l10n.translate('sellCar'),
                  subtitle: l10n.translate('createAd'),
                  onTap: () =>
                      _closeAddMenuAndOpen(sheetContext, AppRoutes.addCar),
                ),
                _AddMenuTile(
                  icon: Icons.storefront,
                  title: l10n.translate('addDealerCar'),
                  subtitle: l10n.translate('forLargeSellers'),
                  onTap: () =>
                      _closeAddMenuAndOpen(sheetContext, AppRoutes.addCar),
                ),
                _AddMenuTile(
                  icon: Icons.local_shipping,
                  title: l10n.translate('orderDelivery'),
                  subtitle: l10n.translate('keyDelivery'),
                  onTap: () =>
                      _closeAddMenuAndOpen(sheetContext, AppRoutes.delivery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= AppBreakpoints.expanded;
        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(
                  currentIndex: currentIndex,
                  onDestinationSelected: (value) =>
                      setState(() => currentIndex = value),
                  onAdd: _openAddMenu,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: currentIndex, children: screens),
                ),
              ],
            ),
          );
        }
        return _buildCompactScaffold(context, l10n);
      },
    );
  }

  Widget _buildCompactScaffold(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      floatingActionButton: AppHoverLift(
        borderRadius: BorderRadius.circular(32),
        hoverScale: 1.06,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            tooltip: l10n.translate('addCar'),
            onPressed: _openAddMenu,
            backgroundColor: Colors.transparent,
            elevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            child: const Icon(Icons.add_rounded, size: 34),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          height: 78,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.16),
          surfaceTintColor: Colors.transparent,
          color: Theme.of(context).cardColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: l10n.translate('home'),
                      isSelected: currentIndex == 0,
                      onTap: () => setState(() => currentIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.search_rounded,
                      selectedIcon: Icons.search_rounded,
                      label: l10n.translate('search'),
                      isSelected: currentIndex == 1,
                      onTap: () => setState(() => currentIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 82),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.favorite_border_rounded,
                      selectedIcon: Icons.favorite_rounded,
                      label: l10n.translate('favorites'),
                      isSelected: currentIndex == 2,
                      onTap: () => setState(() => currentIndex = 2),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person_rounded,
                      label: l10n.translate('profile'),
                      isSelected: currentIndex == 3,
                      onTap: () => setState(() => currentIndex = 3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      right: false,
      child: Container(
        width: 248,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: _DesktopBrand(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: NavigationRail(
                extended: true,
                minExtendedWidth: 218,
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                groupAlignment: -1,
                labelType: NavigationRailLabelType.none,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: Text(l10n.translate('home')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.search_rounded),
                    selectedIcon: const Icon(Icons.manage_search_rounded),
                    label: Text(l10n.translate('search')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.favorite_border_rounded),
                    selectedIcon: const Icon(Icons.favorite_rounded),
                    label: Text(l10n.translate('favorites')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: Text(l10n.translate('profile')),
                  ),
                ],
              ),
            ),
            AppHoverLift(
              borderRadius: BorderRadius.circular(16),
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.translate('addCar')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopBrand extends StatelessWidget {
  const _DesktopBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.directions_car_filled, color: Colors.white),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Text(
            'Auto Market\nGlobal',
            style: TextStyle(fontWeight: FontWeight.w900, height: 1.05),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.muted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.11)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        key: ValueKey(isSelected),
                        color: color,
                        size: 23,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppHoverLift(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: Icon(icon, color: AppColors.primary),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
