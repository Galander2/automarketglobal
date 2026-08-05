import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/car_repository.dart';
import '../widgets/car_card.dart';
import '../widgets/app_hover_lift.dart';

typedef HomeCarsLoader =
    Future<List<Car>> Function({required bool forceRefresh});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.loadCars});

  final HomeCarsLoader? loadCars;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCarsLoader _loadCars;
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    final providedLoader = widget.loadCars;
    if (providedLoader != null) {
      _loadCars = providedLoader;
    } else {
      final repository = CarRepository();
      _loadCars = ({required bool forceRefresh}) =>
          repository.getApprovedCars(forceRefresh: forceRefresh);
    }
    _carsFuture = _loadCars(forceRefresh: false);
  }

  Future<void> _refresh() async {
    final request = _loadCars(forceRefresh: true);
    setState(() {
      _carsFuture = request;
    });
    await request;
  }

  void _retry() {
    setState(() {
      _carsFuture = _loadCars(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto Market Global',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            Text(
              'Найдите подходящий автомобиль',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Car>>(
          future: _carsFuture,
          builder: (context, snapshot) {
            return CustomScrollView(
              key: const PageStorageKey('home-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Новые автомобили',
                    count: snapshot.data?.length,
                    onViewAll: () =>
                        Navigator.pushNamed(context, AppRoutes.search),
                  ),
                ),
                ..._buildCars(context, snapshot),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Автомобили со всего мира',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Проверенные объявления в одном месте',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            Semantics(
              button: true,
              label: 'Открыть поиск автомобилей',
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF2563EB)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Марка, модель или город',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <_HomeAction>[
      const _HomeAction(
        icon: Icons.add_circle_outline,
        title: 'Продать авто',
        subtitle: 'Создать объявление',
        route: AppRoutes.addCar,
      ),
      const _HomeAction(
        icon: Icons.public,
        title: 'Страны',
        subtitle: 'Выбрать рынок',
        route: AppRoutes.countries,
      ),
      const _HomeAction(
        icon: Icons.storefront_outlined,
        title: 'Дилеры',
        subtitle: 'Надёжные продавцы',
        route: AppRoutes.dealers,
      ),
      const _HomeAction(
        icon: Icons.local_shipping_outlined,
        title: 'Доставка',
        subtitle: 'Заказать перевозку',
        route: AppRoutes.delivery,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760 ? 4 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.65 : 1.45,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickActionCard(
                action: action,
                onTap: () => Navigator.pushNamed(context, action.route),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildCars(
    BuildContext context,
    AsyncSnapshot<List<Car>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const [SliverToBoxAdapter(child: _LoadingCars())];
    }

    if (snapshot.hasError) {
      return [
        SliverToBoxAdapter(
          child: _HomeMessage(
            icon: Icons.cloud_off_outlined,
            title: 'Не удалось загрузить автомобили',
            message: 'Проверьте подключение к интернету и попробуйте ещё раз.',
            actionLabel: 'Повторить',
            onAction: _retry,
          ),
        ),
      ];
    }

    final cars = snapshot.data ?? const <Car>[];
    if (cars.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _HomeMessage(
            icon: Icons.directions_car_outlined,
            title: 'Объявлений пока нет',
            message: 'Станьте первым продавцом на площадке.',
            actionLabel: 'Продать автомобиль',
            onAction: () => Navigator.pushNamed(context, AppRoutes.addCar),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.crossAxisExtent >= 900 ? 2 : 1;
            if (columns == 1) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _carItem(context, cars[index]),
                  childCount: cars.length,
                ),
              );
            }
            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.94,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _carItem(context, cars[index]),
                childCount: cars.length,
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _carItem(BuildContext context, Car car) {
    final userId = context.read<AuthProvider?>()?.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CarCard(
        key: ValueKey(car.id),
        car: car,
        favoriteUserId: userId,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.carDetails,
          arguments: {'car': car},
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.count,
    required this.onViewAll,
  });

  final String title;
  final int? count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count == null ? title : '$title ($count)',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(onPressed: onViewAll, child: const Text('Показать все')),
        ],
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, required this.onTap});

  final _HomeAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppHoverLift(
      borderRadius: BorderRadius.circular(18),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(action.icon, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCars extends StatelessWidget {
  const _LoadingCars();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 42),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 58, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
