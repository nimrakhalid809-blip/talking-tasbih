import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/widgets/accessible_widgets.dart';

class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> with WidgetsBindingObserver {
  final _semanticsNode = SemanticsNode();
  Timer? _targetAnnouncementTimer;
  bool _targetAnnounced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _announceScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _targetAnnouncementTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _announceScreen();
    }
  }

  void _announceScreen() async {
    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final tts = ref.read(ttsServiceProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await tts.announceScreen('Counter', settings.language);
      }
    }
  }

  void _handleCounterTap(ZikrModel zikr) async {
    final settings = ref.read(settingsProvider);
    final counter = ref.read(counterProvider.notifier);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    counter.increment(
      target: settings.targetCount,
      mode: settings.voiceAnnouncementMode,
      voiceEnabled: settings.voiceFeedbackEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      strongVibrationEnabled: settings.strongVibrationEnabled,
      onVoiceAnnounce: (prefix, count) {
        tts.speakCount(zikr.displayName, count, settings.language);
      },
      onTargetReached: (reached) {
        if (reached && !_targetAnnounced) {
          _targetAnnounced = true;
          haptic.targetComplete();
          tts.announceTargetComplete(settings.language);
        }
      },
      onVibrate: () => haptic.lightTap(),
      onStrongVibrate: () => haptic.strongVibration(),
    );
  }

  void _handleReset() async {
    final settings = ref.read(settingsProvider);
    final counterState = ref.read(counterProvider);

    if (counterState.count == 0) return;

    final confirmed = await _showResetDialog();
    if (confirmed == true) {
      _targetAnnounced = false;
      _saveToHistory(counterState);
      ref.read(counterProvider.notifier).reset();

      if (settings.voiceFeedbackEnabled) {
        final tts = ref.read(ttsServiceProvider);
        await tts.speak('Counter reset.', awaitCompletion: true);
      }
    }
  }

  Future<bool?> _showResetDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Semantics(
        label: 'Reset current tasbih?',
        child: AlertDialog(
          title: const Text('Reset Current Tasbih?'),
          content: Consumer(
            builder: (context, ref, child) {
              final selectedZikr = ref.read(selectedZikrProvider);
              final counterState = ref.read(counterProvider);
              return Text(
                '${selectedZikr?.displayName ?? "Tasbih"} count: ${counterState.count}',
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveToHistory(CounterState state) {
    if (state.count == 0 || state.startedAt == null) return;

    final zikr = ref.read(selectedZikrProvider);
    if (zikr == null) return;

    final settings = ref.read(settingsProvider);
    final history = HistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      zikrId: zikr.id,
      zikrName: zikr.displayName,
      count: state.count,
      target: settings.targetCount,
      targetCompleted: state.targetReached,
      startedAt: state.startedAt!,
      completedAt: DateTime.now(),
    );

    ref.read(historyProvider.notifier).addHistory(history);
  }

  void _handleUndoReset() {
    ref.read(counterProvider.notifier).undoReset();
    _targetAnnounced = false;

    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final counterState = ref.read(counterProvider);
      final tts = ref.read(ttsServiceProvider);
      tts.speak('Counter restored to ${counterState.count}');
    }
  }

  void _openZikrSelector() async {
    final settings = ref.read(settingsProvider);
    final selectedZikr = ref.read(selectedZikrProvider);
    final result = await showModalBottomSheet<ZikrModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Semantics(
          label: 'Select Zikr',
          child: _ZikrSelectionSheet(
            scrollController: scrollController,
            selectedZikr: selectedZikr,
          ),
        ),
      ),
    );

    if (result != null) {
      ref.read(settingsProvider.notifier).setSelectedZikrId(result.id);
      _targetAnnounced = false;

      if (settings.voiceFeedbackEnabled) {
        final tts = ref.read(ttsServiceProvider);
        await tts.speak('Selected ${result.displayName}');
      }
    }
  }

  void _openTargetSelector() async {
    final settings = ref.read(settingsProvider);
    final targets = [
      {'label': 'No Target', 'value': 0},
      {'label': '33', 'value': 33},
      {'label': '99', 'value': 99},
      {'label': '100', 'value': 100},
      {'label': '300', 'value': 300},
      {'label': '500', 'value': 500},
      {'label': '1000', 'value': 1000},
      {'label': 'Custom', 'value': -1},
    ];

    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => Semantics(
        label: 'Set Target',
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set Target',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: targets.length,
                  itemBuilder: (context, index) {
                    final target = targets[index];
                    final isSelected = settings.targetCount == target['value'];
                    final isCustom = target['value'] == -1;

                    return Semantics(
                      label: target['label'] as String,
                      selected: isSelected,
                      button: true,
                      child: ListTile(
                        title: Text(target['label'] as String),
                        trailing: isCustom
                            ? FutureBuilder<int>(
                                future: null,
                                builder: (ctx, snap) => const Text(''),
                              )
                            : null,
                        selected: isSelected,
                        onTap: () async {
                          if (isCustom) {
                            final custom = await _showCustomTargetDialog();
                            if (custom != null && custom > 0) {
                              if (mounted) {
                                Navigator.pop(context, custom);
                              }
                            }
                          } else {
                            if (mounted) {
                              Navigator.pop(context, target['value'] as int);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result != settings.targetCount) {
      ref.read(settingsProvider.notifier).setTargetCount(result);
      _targetAnnounced = false;

      if (settings.voiceFeedbackEnabled) {
        final tts = ref.read(ttsServiceProvider);
        await tts.speak(result > 0 ? 'Target set to $result' : 'Target removed');
      }
    }
  }

  Future<int?> _showCustomTargetDialog() async {
    final controller = TextEditingController();
    FocusNode? focusNode;

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Target'),
        content: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target Count',
            hintText: 'Enter target count',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
