import '../models/dealer.dart';

const List<Dealer> dealers = [
  Dealer(
    id: 'dealer_001',
    name: 'Asia Auto Logistics',
    country: 'ОАЭ',
    city: 'Dubai',
    description:
        'Крупный дилер с доставкой автомобилей под ключ по Центральной Азии.',
    deliveryCountries: ['Таджикистан', 'Узбекистан', 'Казахстан', 'Кыргызстан'],
    isVerified: true,
    rating: 4.9,
    carsCount: 184,
  ),
  Dealer(
    id: 'dealer_002',
    name: 'Korea Motors Export',
    country: 'Южная Корея',
    city: 'Seoul',
    description:
        'Поставки автомобилей из Кореи с проверкой документов и истории.',
    deliveryCountries: ['Таджикистан', 'Узбекистан', 'Казахстан', 'Россия'],
    isVerified: true,
    rating: 4.8,
    carsCount: 96,
  ),
  Dealer(
    id: 'dealer_003',
    name: 'China EV Cars',
    country: 'Китай',
    city: 'Guangzhou',
    description:
        'Электромобили и новые автомобили из Китая с международной доставкой.',
    deliveryCountries: ['Вся Центральная Азия', 'Кавказ', 'ОАЭ'],
    isVerified: true,
    rating: 4.7,
    carsCount: 221,
  ),
];
