import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/qibla_service.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with WidgetsBindingObserver {
  QiblaData? _lastQiblaData;
  Timer? _voiceAnnouncementTimer;
  DateTime? _lastAnnouncement;
  QiblaDirection? _lastAnnouncedDirection;
  bool _isAligned = false;
  bool _hasAnnouncedCalibration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _voiceAnnouncementTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeServices();
    } else if (state == AppLifecycleState.paused) {
      _voiceAnnouncementTimer?.cancel();
    }
  }

  Future<void> _initializeServices() async {
    await _refreshLocation();
    Future.delayed(const Duration(milliseconds: 500), _announceScreen);
    final settings = ref.read(settingsProvider);
    if (settings.qiblaVoiceGuidance) {
      _startVoiceGuidance();
    }
  }

  void _announceScreen() async {
    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final tts = ref.read(ttsServiceProvider);
      await tts.announceScreen('Qibla Direction', settings.language);
    }
  }

  void _startVoiceGuidance() {
    _voiceAnnouncementTimer?.cancel();
    _voiceAnnouncementTimer =
        Timer.periodic(const Duration(seconds: 3), (_) {
      _announceQiblaGuidance();
    });
  }

  void _announceQiblaGuidance() {
    final settings = ref.read(settingsProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    final svc = ref.read(qiblaServiceProvider);

    if (!settings.qiblaVoiceGuidance || _lastQiblaData == null) return;

    final now = DateTime.now();
    if (_lastAnnouncement != null &&
        now.difference(_lastAnnouncement!).inSeconds < 3) {
      return;
    }

    final qiblaData = _lastQiblaData!;

    // Announce calibration need once
    if (qiblaData.needsCalibration && !_hasAnnouncedCalibration) {
      _hasAnnouncedCalibration = true;
      tts.speak(
        'Compass accuracy is low. Please calibrate by moving your device '
        'in a figure-eight pattern.',
      );
      _lastAnnouncement = now;
      return;
    }

    final isAligned = qiblaData.isAligned;

    if (isAligned && !_isAligned) {
      _isAligned = true;
      tts.speak(
          svc.getVoiceGuidance(QiblaDirection.perfect, settings.language));
      if (settings.qiblaVibrationGuidance) {
        haptic.qiblaAligned();
      }
    } else if (!isAligned) {
      _isAligned = false;
      final direction = qiblaData.direction;
      if (direction != _lastAnnouncedDirection) {
        _lastAnnouncedDirection = direction;
        tts.speak(svc.getVoiceGuidance(direction, settings.language));
        if (settings.qiblaVibrationGuidance) {
          switch (direction) {
            case QiblaDirection.perfect:
              haptic.qiblaAligned();
              break;
            case QiblaDirection.turnSlightlyLeft:
            case QiblaDirection.turnSlightlyRight:
              haptic.lightTap();
              break;
            default:
              break;
          }
        }
      }
    }

    _lastAnnouncement = now;
  }

  Future<void> _refreshLocation() async {
    final qiblaService = ref.read(qiblaServiceProvider);
    await qiblaService.initialize();
  }

  void _speakQiblaDirection() {
    final settings = ref.read(settingsProvider);
    final tts = ref.read(ttsServiceProvider);
    final svc = ref.read(qiblaServiceProvider);
    final data = _lastQiblaData;
    if (data == null) {
      tts.speak('Compass data not available. Please wait or refresh location.');
      return;
    }
    tts.speak(svc.getCurrentHeadingAnnouncement(data, settings.language));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final qiblaDataAsync = ref.watch(qiblaDataProvider);

    ref.listen<AsyncValue<QiblaData?>>(qiblaDataProvider, (prev, next) {
      next.whenData((data) {
        if (data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _lastQiblaData = data;
              });
              // Vibrate when aligned within 3 degrees
              if (data.isAligned &&
                  !_isAligned &&
                  settings.qiblaVibrationGuidance) {
                ref.read(hapticServiceProvider).qiblaAligned();
                _isAligned = true;
              } else if (!data.isAligned) {
                _isAligned = false;
              }
            }
          });
        }
      });
    });

    final qiblaService = ref.read(qiblaServiceProvider);

    return Semantics(
      label: 'Qibla Direction screen',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Qibla Direction'),
          actions: [
            Semantics(
              label: 'Refresh location',
              hint: 'Double tap to refresh your GPS location',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _refreshLocation,
                tooltip: 'Refresh Location',
              ),
            ),
            Semantics(
              label:
                  'Voice guidance ${settings.qiblaVoiceGuidance ? 'on' : 'off'}',
              hint: 'Double tap to toggle voice guidance',
              button: true,
              child: IconButton(
                icon: Icon(
                  settings.qiblaVoiceGuidance
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
                onPressed: () {
                  final newValue = !settings.qiblaVoiceGuidance;
                  ref
                      .read(settingsProvider.notifier)
                      .setQiblaVoiceGuidance(newValue);
                  if (newValue) {
                    _startVoiceGuidance();
                  } else {
                    _voiceAnnouncementTimer?.cancel();
                  }
                },
                tooltip: 'Toggle Voice Guidance',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: qiblaDataAsync.when(
            data: (data) {
              if (data == null) return _buildNoDataWidget();
              return _buildCompassWidget(data, settings, qiblaService);
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
      label: 'Loading compass data. Please wait.',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Getting your location...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    // Speak the error for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (settings.voiceFeedbackEnabled) {
        final tts = ref.read(ttsServiceProvider);
        tts.speak('Error: $error');
      }
    });

    return Semantics(
      label: 'Error loading compass. $error',
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
                'Unable to access compass or location',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Try Again',
                hint: 'Double tap to retry',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: _refreshLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for compass...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Refresh compass',
            button: true,
            child: ElevatedButton.icon(
              onPressed: _refreshLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassWidget(
    QiblaData data,
    SettingsModel settings,
    QiblaService qiblaService,
  ) {
    final isAligned = data.isAligned;

    return Semantics(
      label: isAligned
          ? 'You are facing the Qibla. Perfect alignment.'
          : 'Turn ${_getTurnInstruction(data.direction)} to face the Qibla.',
      hint: isAligned
          ? 'You are aligned with the Kaaba in Makkah.'
          : 'Rotate your phone until you face the Qibla.',
      liveRegion: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (data.needsCalibration)
              _buildCalibrationBanner(),
            if (data.needsCalibration) const SizedBox(height: 12),
            _buildQiblaInfoCard(data, settings),
            const SizedBox(height: 24),
            _buildCompass(data, settings),
            const SizedBox(height: 24),
            _buildAlignmentStatus(data),
            const SizedBox(height: 16),
            _buildSpeakButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationBanner() {
    return Semantics(
      label:
          'Compass calibration needed. Move your device in a figure-eight pattern.',
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade400),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compass Calibration Needed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    'Move your device in a figure-eight pattern to calibrate.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakButton() {
    return Semantics(
      label: 'Speak Qibla Direction',
      hint: 'Double tap to hear the current compass heading and Qibla direction',
      button: true,
      child: ElevatedButton.icon(
        onPressed: _speakQiblaDirection,
        icon: const Icon(Icons.record_voice_over),
        label: const Text('Speak Qibla Direction'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }

  String _getTurnInstruction(QiblaDirection direction) {
    switch (direction) {
      case QiblaDirection.perfect:
        return 'perfect';
      case QiblaDirection.turnSlightlyLeft:
        return 'slightly left';
      case QiblaDirection.turnLeft:
        return 'left';
      case QiblaDirection.turnFarLeft:
        return 'far left';
      case QiblaDirection.turnSlightlyRight:
        return 'slightly right';
      case QiblaDirection.turnRight:
        return 'right';
      case QiblaDirection.turnFarRight:
        return 'far right';
      case QiblaDirection.turnAround:
        return 'around';
    }
  }

  Widget _buildQiblaInfoCard(QiblaData data, SettingsModel settings) {
    return Semantics(
      label:
          'Qibla is at ${data.qiblaDirection.toStringAsFixed(0)} degrees. '
          'Currently facing ${data.heading.toStringAsFixed(0)} degrees.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Qibla Direction',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Kaaba at ${data.qiblaDirection.toStringAsFixed(0)}°',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Heading: ${data.heading.toStringAsFixed(0)}°',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Kaaba in Makkah',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(QiblaData data, SettingsModel settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = settings.highContrastMode
        ? Colors.black
        : isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white;
    final primaryColor = settings.highContrastMode
        ? const Color(0xFF00E676)
        : Theme.of(context).colorScheme.primary;

    // Compass rose rotates opposite to heading so N always points north
    // Qibla needle rotates to show Qibla absolute bearing, compensated for heading
    final compassRoseAngle = -data.heading * (math.pi / 180);
    // The needle should point toward Qibla in absolute north-up terms.
    // Since compass rose is rotated by -heading, needle rotates by (qiblaDirection - heading)
    final qiblaArrowAngle =
        (data.qiblaDirection - data.heading) * (math.pi / 180);

    return Semantics(
      label:
          'Compass. Qibla needle points ${data.qiblaOffset.toStringAsFixed(0)} degrees '
          '${_isClockwiseOffset(data.qiblaOffset) ? 'to the right' : 'to the left'}.',
      excludeSemantics: false,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Compass rose rotates as device rotates
            Transform.rotate(
              angle: compassRoseAngle,
              child: _buildCompassRose(primaryColor),
            ),
            // Qibla needle stays pointed at Qibla regardless of rotation
            Transform.rotate(
              angle: qiblaArrowAngle,
              child: _buildQiblaArrow(data, settings),
            ),
            // Center dot
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isClockwiseOffset(double offset) => offset <= 180;

  Widget _buildCompassRose(Color color) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: CompassRosePainter(color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildQiblaArrow(QiblaData data, SettingsModel settings) {
    final isAligned = data.isAligned;
    final arrowColor = isAligned
        ? const Color(0xFF00C853)
        : settings.highContrastMode
            ? Colors.white
            : Theme.of(context).colorScheme.secondary;

    return SizedBox(
      width: 60,
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arrow head pointing up (toward Qibla)
          Icon(
            Icons.navigation,
            size: 48,
            color: arrowColor,
          ),
          // Stem
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: arrowColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentStatus(QiblaData data) {
    final isAligned = data.isAligned;

    return Semantics(
      label: isAligned
          ? 'Perfect Qibla alignment. You are facing Makkah.'
          : 'Not aligned. ${_getTurnInstruction(data.direction)} to face Qibla.',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isAligned
              ? const Color(0xFF00C853).withOpacity(0.2)
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAligned
                ? const Color(0xFF00C853)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAligned ? Icons.check_circle : Icons.explore,
              color: isAligned
                  ? const Color(0xFF00C853)
                  : Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                isAligned
                    ? 'Perfect Qibla Alignment'
                    : 'Turn ${_getTurnInstruction(data.direction)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isAligned
                          ? const Color(0xFF00C853)
                          : Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassRosePainter extends CustomPainter {
  final Color color;

  CompassRosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    const cardinals = ['N', 'E', 'S', 'W'];
    const cardinalAngles = [0, 90, 180, 270];

    for (int i = 0; i < 360; i += 10) {
      final angle = i * (math.pi / 180);
      final isCardinal = i % 90 == 0;
      final isOrdinal = i % 45 == 0 && !isCardinal;

      final startRadius = isCardinal
          ? radius - 24
          : isOrdinal
              ? radius - 18
              : radius - 10;
      final endRadius = radius;

      final startX =
          center.dx + startRadius * math.cos(angle - math.pi / 2);
      final startY =
          center.dy + startRadius * math.sin(angle - math.pi / 2);
      final endX = center.dx + endRadius * math.cos(angle - math.pi / 2);
      final endY = center.dy + endRadius * math.sin(angle - math.pi / 2);

      paint.strokeWidth = isCardinal ? 3 : 1;
      paint.color = isCardinal ? color.withOpacity(0.8) : color;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw N/E/S/W labels
    for (int i = 0; i < 4; i++) {
      final angle = cardinalAngles[i] * (math.pi / 180);
      final labelRadius = radius - 38;
      final x = center.dx + labelRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + labelRadius * math.sin(angle - math.pi / 2);

      textPainter.text = TextSpan(
        text: cardinals[i],
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassRosePainter oldDelegate) =>
      oldDelegate.color != color;
}
