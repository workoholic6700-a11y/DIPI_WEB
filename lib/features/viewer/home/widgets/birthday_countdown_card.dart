import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/date_x.dart';

/// A celebratory birthday countdown card.
class BirthdayCountdownCard extends StatelessWidget {
  const BirthdayCountdownCard({
    super.key,
    required this.birthday,
    required this.name,
  });

  final DateTime birthday;
  final String name;

  @override
  Widget build(BuildContext context) {
    final days = birthday.daysUntilNextAnniversary();
    final nextAge = birthday.ageOn() + (days == 0 ? 0 : 1);
    final isToday = days == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B72CF), Color(0xFFE8749E)],
        ),
        borderRadius: AppDimens.brLg,
        boxShadow: [
          BoxShadow(
              color: AppColors.pink.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cake_rounded, color: Colors.white, size: 32)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -4, duration: 1200.ms),
          ),
          const SizedBox(width: AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? 'Happy Birthday, $name! 🎉'
                      : 'Birthday Countdown',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  isToday
                      ? 'You\'re turning ${birthday.ageOn()} today!'
                      : 'Turning $nextAge on ${birthday.nextAnniversary().dayMonth}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isToday)
            Column(
              children: [
                Text('$days',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        height: 1)),
                const Text('days',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }
}
