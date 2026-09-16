import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';
import '../village/nature/sakela_than.dart';

/// Sakela Than — the family's Kirat sacred spot. We are **Kirat Rai**; we
/// worship nature and our ancestors **Sumnima** (earth mother) & **Paruhang**
/// (sky father). This gentle page honours that identity: the sacred grove, the
/// Sakela festival (Ubhauli & Udhauli) and the Sili dance. Nature-worship, not
/// a temple.
class SakelaThanScreen extends StatelessWidget {
  const SakelaThanScreen({super.key});

  // A soft mossy-green wash that feels like a forest clearing.
  static const _grove = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEAF3DE), Color(0xFFF4F1E4)],
  );

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: 'Sakela Than',
      subtitle: 'Our Kirat sacred place · प्रकृति पूजा',
      emoji: '🌿',
      gradient: _grove,
      particles: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heroGrove(),
          const SizedBox(height: AppDimens.xl),
          _deities(),
          const SizedBox(height: AppDimens.xl),
          _sectionTitle('The Sakela Festival', '🥁'),
          const SizedBox(height: AppDimens.md),
          _festival(),
          const SizedBox(height: AppDimens.xl),
          _sectionTitle('What we believe', '🍃'),
          const SizedBox(height: AppDimens.md),
          _beliefs(),
          const SizedBox(height: AppDimens.xl),
          _closing(),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }

  // ── The living grove at the top ──
  Widget _heroGrove() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDEBC6), Color(0xFFCFE3B4)],
        ),
        borderRadius: AppDimens.brXl,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF5C9A4E).withValues(alpha: 0.20),
              blurRadius: 22,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text('हाम्रो थान',
              style: handwriting(
                  fontSize: 30, color: const Color(0xFF4F7A3A))),
          const SizedBox(height: 4),
          const SakelaThan(width: 240),
          const SizedBox(height: 8),
          Text(
            'A quiet clearing under the trees — where the Rai family bows to '
            'the earth and the sky.',
            textAlign: TextAlign.center,
            style: handwriting(fontSize: 19, color: const Color(0xFF5A5340)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Sumnima & Paruhang ──
  Widget _deities() {
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _deityCard(
            emoji: '🌏',
            name: 'Sumnima',
            role: 'Earth Mother',
            note: 'The soil, the harvest, the rivers — she gives and holds all life.',
            color: const Color(0xFF7FB86B),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: _deityCard(
            emoji: '☀️',
            name: 'Paruhang',
            role: 'Sky Father',
            note: 'The sun, the rain, the wind — he watches over from above.',
            color: const Color(0xFF6FA8D6),
          ),
        ),
      ],
      ),
    );
  }

  Widget _deityCard({
    required String emoji,
    required String name,
    required String role,
    required String note,
    required Color color,
  }) {
    return PaperCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 10),
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textPrimary)),
          Text(role,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: color)),
          const SizedBox(height: 8),
          Text(note,
              textAlign: TextAlign.center,
              style: handwriting(fontSize: 16, color: const Color(0xFF6B5B7B))),
        ],
      ),
    );
  }

  // ── The Sakela festival ──
  Widget _festival() {
    return Column(
      children: [
        PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Twice a year the whole village gathers at the than to dance the '
                'Sakela Sili — steps that copy the birds, the animals and the '
                'work of the fields. Drums (dhol) and cymbals (jhyamta) lead, and '
                'everyone circles together.',
                style: handwriting(
                    fontSize: 19, color: const Color(0xFF5A5340), height: 1.35),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _seasonChip(
                      title: 'Ubhauli',
                      when: 'Baisakh · Spring',
                      note: 'We ask for a good planting and climb up to the hills.',
                      color: const Color(0xFF7FB86B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _seasonChip(
                      title: 'Udhauli',
                      when: 'Mangsir · Autumn',
                      note: 'We give thanks for the harvest and come down to the valley.',
                      color: const Color(0xFFE0A93E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seasonChip({
    required String title,
    required String when,
    required String note,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppDimens.brMd,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: color)),
          Text(when,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(note,
              style:
                  handwriting(fontSize: 15, color: const Color(0xFF6B5B7B))),
        ],
      ),
    );
  }

  // ── Beliefs as little notes ──
  Widget _beliefs() {
    const notes = [
      ('🌱', 'We worship nature — the land, the water and the forest are sacred.'),
      ('🙏', 'We remember our ancestors and thank them at the than.'),
      ('🐓', 'Offerings are simple: flowers, leaves, grain and a little of what we grow.'),
      ('🏔️', 'Our roots are in the eastern hills — Kirat land.'),
    ];
    return Wrap(
      spacing: AppDimens.md,
      runSpacing: AppDimens.md,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < notes.length; i++)
          StickyNote(
            emoji: notes[i].$1,
            text: notes[i].$2,
            color: const [
              Color(0xFFE7F1D5),
              Color(0xFFFDF0D2),
              Color(0xFFDCEFE0),
              Color(0xFFEDE6D2),
            ][i % 4],
            rotation: i.isEven ? -0.03 : 0.03,
            width: 168,
          ).animate().fadeIn(delay: (i * 90).ms).scale(
              begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ],
    );
  }

  Widget _closing() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCEFE0), Color(0xFFEAF3DE)],
        ),
        borderRadius: AppDimens.brXl,
      ),
      child: Column(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(
            'Sewa!',
            style: handwriting(fontSize: 26, color: const Color(0xFF4F7A3A)),
          ),
          const SizedBox(height: 4),
          Text(
            'We are Kirat. We belong to the earth and the sky, and to each other.',
            textAlign: TextAlign.center,
            style: handwriting(fontSize: 19, color: const Color(0xFF5A5340)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
