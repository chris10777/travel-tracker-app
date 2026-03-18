import 'package:intl/intl.dart';

String formatPopulation(int value) {
  final formatter = NumberFormat('#,###', 'de_DE');
  return formatter.format(value);
}

