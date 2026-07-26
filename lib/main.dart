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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
          height: 92,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.16),
          surfaceTintColor: Colors.transparent,
          color: Theme.of(context).cardColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
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
                  const SizedBox(width: 98),
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

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isEmphasized = widget.isSelected || _isHovered || _isFocused;
    final color = isEmphasized ? AppColors.primary : AppColors.muted;
    final scale = _isPressed ? 0.97 : (_isHovered ? 1.035 : 1.0);

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() {
            _isHovered = false;
            _isPressed = false;
          }),
          child: FocusableActionDetector(
            onShowFocusHighlight: (value) =>
                setState(() => _isFocused = value),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.13)
                      : _isHovered
                          ? AppColors.primary.withValues(alpha: 0.07)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isEmphasized
                        ? AppColors.primary.withValues(alpha: 0.72)
                        : Colors.transparent,
                  ),
                  boxShadow: isEmphasized
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : const [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onTap,
                    onHighlightChanged: (value) =>
                        setState(() => _isPressed = value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: Icon(
                              widget.isSelected
                                  ? widget.selectedIcon
                                  : widget.icon,
                              key: ValueKey(widget.isSelected),
                              color: color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 12.5,
                              fontWeight: widget.isSelected
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
