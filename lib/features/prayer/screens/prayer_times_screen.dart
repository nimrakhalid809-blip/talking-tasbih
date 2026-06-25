import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> with WidgetsBindingObserver {
  Timer? _countdownTimer;
  Timer? _refreshTimer;
  DateTime _now = DateTime.now();
  int _countdownSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();
    _startTimers();
    _announceScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _announceScreen();
      _now = DateTime.now();
    }
  }

  void _startTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        final prayerTimes = ref.read(prayerTimesProvider).valueOrNull;
        final nextPrayer = prayerTimes?.nextPrayer;
        if (nextPrayer != null) {
          _countdownSeconds = nextPrayer.time.difference(_now).inSeconds;
        }
      });
    });

    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      ref.invalidate(prayerTimesProvider);
    });
  }

  void _announceScreen() async {
    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final tts = ref.read(ttsServiceProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      await tts.announceScreen('Prayer Times', settings.language);

      final prayerTimes = ref.read(prayerTimesProvider).valueOrNull;
      final nextPrayer = prayerTimes?.nextPrayer;
      if (nextPrayer != null) {
        await tts.speak(
          'Next prayer: ${nextPrayer.name.english} in ${nextPrayer.getTimeRemaining()}',
        );
      }
    }
  }

  void _showMethodSelector(BuildContext context) {
    _showSelectionBottomSheet(
      context: context,
      title: 'Select Calculation Method',
      values: PrayerCalculationMethod.values,
      currentValue: ref.read(settingsProvider).calculationMethod,
      labelBuilder: (method) => _getMethodLabel(method),
      onSelected: (method) {
        ref.read(settingsProvider.notifier).setCalculationMethod(method);
      },
    );
  }

  void _showFiqhSelector(BuildContext context) {
    _showSelectionBottomSheet(
      context: context,
      title: 'Select Fiqh',
      values: FiqhMethod.values,
      currentValue: ref.read(settingsProvider).fiqhMethod,
      labelBuilder: (fiqh) => _getFiqhLabel(fiqh),
      onSelected: (fiqh) {
        ref.read(settingsProvider.notifier).setFiqhMethod(fiqh);
      },
    );
  }

  void _showSelectionBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> values,
    required T currentValue,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: values.length,
                itemBuilder: (context, index) {
                  final value = values[index];
                  final isSelected = value == currentValue;

                  return Semantics(
                    label: labelBuilder(value),
                    selected: isSelected,
                    button: true,
                    child: ListTile(
                      title: Text(labelBuilder(value)),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(value);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodLabel(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case PrayerCalculationMethod.muslimWorldLeague:
        return 'Muslim World League';
      case PrayerCalculationMethod.makkah:
        return 'Umm Al-Qura, Makkah';
      case PrayerCalculationMethod.egyptian:
        return 'Egyptian General Authority';
      case PrayerCalculationMethod.isna:
        return 'ISNA (North America)';
    }
  }

  String _getFiqhLabel(FiqhMethod fiqh) {
    switch (fiqh) {
      case FiqhMethod.hanafi:
        return 'Hanafi';
      case FiqhMethod.shafii:
        return "Shafi'i";
      case FiqhMethod.maliki:
        return 'Maliki';
      case FiqhMethod.hanbali:
        return 'Hanbali';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return Semantics(
      label: 'Prayer Times screen',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Times'),
          actions: [
            Semantics(
              label: 'Select calculation method',
              hint: 'Double tap to choose prayer calculation method',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showMethodSelector(context),
                tooltip: 'Calculation Method',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: prayerTimesAsync.when(
            data: (data) {
              if (data == null) {
                return _buildNoDataWidget();
              }
              return _buildPrayerTimesWidget(data, settings);
            },
            loading: () => _buildLoadingWidget(),
            error: (e, _) => _buildErrorWidget(e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Semantics(
      label: 'Loading prayer times. Please wait.',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Calculating prayer times...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final settings = ref.read(settingsProvider);

    return Semantics(
      label: 'Error loading prayer times: $error',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Location permission required',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please grant location permission to calculate accurate prayer times.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(prayerTimesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Text('No prayer times available'),
    );
  }

  Widget _buildPrayerTimesWidget(DailyPrayerTimes data, SettingsModel settings) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateTimeHeader(data),
          const SizedBox(height: 16),
          _buildNextPrayerCard(data, settings),
          const SizedBox(height: 24),
          Expanded(
            child: _buildPrayerTiles(data),
          ),
          const SizedBox(height: 16),
          _buildFiqhSelector(settings),
        ],
      ),
    );
  }

  Widget _buildDateTimeHeader(DailyPrayerTimes data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              data.getFormattedDate(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(DailyPrayerTimes data, SettingsModel settings) {
    final nextPrayer = data.nextPrayer;
    if (nextPrayer == null) {
      return const SizedBox.shrink();
    }

    final remaining = nextPrayer.time.difference(_now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    final prayerColor = _getPrayerColor(nextPrayer.name);

    return Semantics(
      label: 'Next prayer: ${nextPrayer.name.english}, in $hours hours $minutes minutes',
      liveRegion: true,
      child: Card(
        color: prayerColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPrayerIcon(nextPrayer.name),
                        color: prayerColor,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Prayer',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            nextPrayer.name.english,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: prayerColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nextPrayer.getFormattedTime(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: prayerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: prayerColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          hours > 0
                              ? '${hours}h ${minutes}m ${seconds}s'
                              : '${minutes}m ${seconds}s',
                          style: TextStyle(
                            color: prayerColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTiles(DailyPrayerTimes data) {
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: data.prayers.length,
        separatorBuilder: (ctx, i) {
          final prayer = data.prayers[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: _getPrayerColor(prayer.name).withOpacity(0.3),
            ),
          );
        },
        itemBuilder: (context, index) {
          final prayer = data.prayers[index];
          return _buildPrayerTile(prayer);
        },
      ),
    );
  }

  Widget _buildPrayerTile(PrayerTimeModel prayer) {
    final prayerColor = _getPrayerColor(prayer.name);

    return Semantics(
      label: '${prayer.name.english} at ${prayer.getFormattedTime()}',
      hint: prayer.isNext ? 'This is the next prayer' : null,
      button: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: prayer.isNext ? prayerColor : prayerColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPrayerIcon(prayer.name),
                color: prayer.isNext ? Colors.white : prayerColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                prayer.name.english,
                style: TextStyle(
                  fontWeight: prayer.isNext ? FontWeight.bold : FontWeight.normal,
                  color: prayer.isNext
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            Text(
              prayer.getFormattedTime(),
              style: TextStyle(
                fontWeight: prayer.isNext ? FontWeight.bold : FontWeight.normal,
                color: prayer.isNext
                    ? prayerColor
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiqhSelector(SettingsModel settings) {
    final fiqh = settings.fiqhMethod;
    return Semantics(
      label: 'Calculation: ${_getMethodLabel(settings.calculationMethod)}, Fiqh: ${_getFiqhLabel(fiqh)}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.gavel, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fiqh: ${_getFiqhLabel(fiqh)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => _showFiqhSelector(context),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPrayerColor(PrayerName name) {
    switch (name) {
      case PrayerName.fajr:
        return AppColors.fajr;
      case PrayerName.sunrise:
        return AppColors.sunrise;
      case PrayerName.dhuhr:
        return AppColors.dhuhr;
      case PrayerName.asr:
        return AppColors.asr;
      case PrayerName.maghrib:
        return AppColors.maghrib;
      case PrayerName.isha:
        return AppColors.isha;
    }
  }

  IconData _getPrayerIcon(PrayerName name) {
    switch (name) {
      case PrayerName.fajr:
        return Icons.nights_stay;
      case PrayerName.sunrise:
        return Icons.wb_twilight;
      case PrayerName.dhuhr:
        return Icons.wb_sunny;
      case PrayerName.asr:
        return Icons.wb_cloudy;
      case PrayerName.maghrib:
        return Icons.brightness_3;
      case PrayerName.isha:
        return Icons.nightlight_round;
    }
  }
}
