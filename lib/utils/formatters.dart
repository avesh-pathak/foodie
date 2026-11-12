import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

String currency(num value) {
  final int rounded = value.round();
  final String digits = rounded.abs().toString();
  final StringBuffer buffer = StringBuffer();
  if (digits.length <= 3) {
    buffer.write(digits);
  } else {
    final String lastThree = digits.substring(digits.length - 3);
    String rest = digits.substring(0, digits.length - 3);
    final List<String> groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    buffer
      ..write(groups.join(','))
      ..write(',')
      ..write(lastThree);
  }
  return '₹${rounded < 0 ? '-' : ''}${buffer.toString()}';
}

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) {
  final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final String minute = date.minute.toString().padLeft(2, '0');
  final String suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '${date.day} ${_months[date.month - 1]}, $hour:$minute $suffix';
}

String formatShortDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]}';
}

String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

void showFoodieSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_outline_rounded,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(icon, color: context.foodie.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        action: action,
        duration: const Duration(seconds: 3),
      ),
    );
}
