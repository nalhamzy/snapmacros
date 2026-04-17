import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/models/user_profile.dart';
import '../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

  Sex _sex = Sex.male;
  int _age = 25;
  double _heightCm = 175;
  double _weightKg = 75;
  Activity _activity = Activity.moderate;
  Goal _goal = Goal.maintain;

  @override
  Widget build(BuildContext context) {
    final profile = ref.read(profileProvider);
    if (profile.onboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ref.read(screenProvider.notifier).go(AppScreen.home));
    }

    return SafeArea(
      child: ResponsiveContentBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.s(22), vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 22),
              _Header(step: _step),
              const SizedBox(height: 24),
              Expanded(child: _body()),
              GradientButton(
                label: _step < 5 ? 'Continue' : 'Create My Plan',
                icon: Icons.arrow_forward_rounded,
                onPressed: _next,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _IntroStep();
      case 1:
        return _SexStep(
            sex: _sex, onChanged: (v) => setState(() => _sex = v));
      case 2:
        return _AgeStep(
            age: _age, onChanged: (v) => setState(() => _age = v));
      case 3:
        return _HeightWeightStep(
            heightCm: _heightCm,
            weightKg: _weightKg,
            onHeight: (v) => setState(() => _heightCm = v),
            onWeight: (v) => setState(() => _weightKg = v));
      case 4:
        return _ActivityStep(
            activity: _activity,
            onChanged: (v) => setState(() => _activity = v));
      case 5:
      default:
        return _GoalStep(
            goal: _goal, onChanged: (v) => setState(() => _goal = v));
    }
  }

  Future<void> _next() async {
    if (_step < 5) {
      setState(() => _step++);
      return;
    }
    await ref.read(profileProvider.notifier).completeOnboarding(
          sex: _sex,
          age: _age,
          heightCm: _heightCm,
          weightKg: _weightKg,
          activity: _activity,
          goal: _goal,
        );
    ref.read(screenProvider.notifier).go(AppScreen.home);
  }
}

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('SnapMacros',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('AI Macro & Calorie Tracker',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final active = i <= step;
            return Container(
              width: 28, height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _IntroStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Snap. Track. Hit your macros.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Point your camera at food — SnapMacros estimates calories, protein, carbs and fat in seconds. Adjust portions with a tap, never over-count.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 22),
          _Bullet(icon: Icons.photo_camera_rounded, text: 'AI-powered photo logging (3 free scans/day).'),
          _Bullet(icon: Icons.tune_rounded, text: 'Tap any item to fine-tune grams — never lie to yourself.'),
          _Bullet(icon: Icons.auto_graph_rounded, text: 'Adaptive macros: targets recompute as you log weight.'),
          _Bullet(icon: Icons.search_rounded, text: 'Text search + common-food database built-in.'),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _SexStep extends StatelessWidget {
  final Sex sex;
  final ValueChanged<Sex> onChanged;
  const _SexStep({required this.sex, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Biological sex',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('We use this to calculate your basal metabolic rate.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              for (final s in Sex.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: InkWell(
                      onTap: () => onChanged(s),
                      borderRadius: BorderRadius.circular(20),
                      child: SectionCard(
                        background: sex == s
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : null,
                        child: Column(
                          children: [
                            Icon(
                                s == Sex.male
                                    ? Icons.male_rounded
                                    : Icons.female_rounded,
                                color: sex == s
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                size: 40),
                            const SizedBox(height: 8),
                            Text(s == Sex.male ? 'Male' : 'Female',
                                style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeStep extends StatelessWidget {
  final int age;
  final ValueChanged<int> onChanged;
  const _AgeStep({required this.age, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How old are you?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              children: [
                Text('$age',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        )),
                Slider(
                  min: 14, max: 85,
                  divisions: 71,
                  value: age.toDouble(),
                  onChanged: (v) => onChanged(v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeightWeightStep extends StatelessWidget {
  final double heightCm;
  final double weightKg;
  final ValueChanged<double> onHeight;
  final ValueChanged<double> onWeight;
  const _HeightWeightStep({
    required this.heightCm,
    required this.weightKg,
    required this.onHeight,
    required this.onWeight,
  });
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Body metrics',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              children: [
                Text('Height: ${heightCm.round()} cm',
                    style: Theme.of(context).textTheme.titleLarge),
                Slider(
                  min: 130, max: 220,
                  divisions: 90,
                  value: heightCm,
                  onChanged: onHeight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              children: [
                Text('Weight: ${weightKg.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.titleLarge),
                Slider(
                  min: 35, max: 200,
                  divisions: 330,
                  value: weightKg,
                  onChanged: onWeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStep extends StatelessWidget {
  final Activity activity;
  final ValueChanged<Activity> onChanged;
  const _ActivityStep({required this.activity, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final options = {
      Activity.sedentary: ['Sedentary', 'Desk job, little exercise'],
      Activity.light: ['Light', '1–3 workouts / week'],
      Activity.moderate: ['Moderate', '3–5 workouts / week'],
      Activity.active: ['Active', '6–7 workouts / week'],
      Activity.athlete: ['Athlete', '2+ sessions per day'],
    };
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How active are you?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final e in options.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onChanged(e.key),
                borderRadius: BorderRadius.circular(18),
                child: SectionCard(
                  padding: const EdgeInsets.all(16),
                  background: activity == e.key
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value[0],
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(e.value[1],
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (activity == e.key)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final Goal goal;
  final ValueChanged<Goal> onChanged;
  const _GoalStep({required this.goal, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final options = {
      Goal.lose: ['Lose weight', '−500 kcal / day'],
      Goal.recomp: ['Recomp / lean out', '−150 kcal · high protein'],
      Goal.maintain: ['Maintain', 'Stay at current weight'],
      Goal.gain: ['Gain muscle', '+300 kcal · high protein'],
    };
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your goal',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final e in options.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onChanged(e.key),
                borderRadius: BorderRadius.circular(18),
                child: SectionCard(
                  padding: const EdgeInsets.all(16),
                  background: goal == e.key
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value[0],
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(e.value[1],
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (goal == e.key)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
