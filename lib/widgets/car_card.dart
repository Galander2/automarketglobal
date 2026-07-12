import 'package:flutter/material.dart';
import 'package:flutter_application_1_car_sales/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фото
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: car.imageUrl.isNotEmpty
                  ? Image.network(
                      car.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.directions_car,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Информация
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  car.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Цена
                Text(
                  '\$${car.price}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 10),

                // Характеристики
                Row(
                  children: [
                    _SpecItem(
                      icon: Icons.calendar_today,
                      text: '${car.year}',
                    ),
                    const SizedBox(width: 16),
                    _SpecItem(
                      icon: Icons.speed,
                      text: '${car.mileage} km',
                    ),
                    const SizedBox(width: 16),
                    _SpecItem(
                      icon: Icons.location_on,
                      text: car.city.isNotEmpty ? car.city : '—',
                    ),
                  ],
                ),

                // Страна и статус
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (car.route.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.route,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              car.route,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}