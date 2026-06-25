import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension BuildContextAccessibilityExtension on BuildContext {
  void announceForAccessibility(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  void announceScreen(String screenName) {
    SemanticsService.announce(
      'Talking Tasbih Counter. $screenName screen.',
      TextDirection.ltr,
    );
  }
}

class AccessibilityFocusNode {
  AccessibilityFocusNode._();

  static void requestFocus(BuildContext context) {
    SemanticsService.announce('', TextDirection.ltr);
  }
}

mixin AccessibilityAnnouncer<T extends StatefulWidget> on State<T> {
  String get semanticsLabel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleAnnouncement();
  }

  void _scheduleAnnouncement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SemanticsService.announce(semanticsLabel, TextDirection.ltr);
      }
    });
  }
}

void accessibleShowDialog({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? barrierLabel,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    builder: (context) => Semantics(
      label: barrierLabel ?? '',
      container: true,
      child: builder(context),
    ),
  );
}

Future<T?> accessibleShowModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? accessibilityLabel,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    builder: (context) => Semantics(
      label: accessibilityLabel ?? '',
      container: true,
      child: builder(context),
    ),
  );
}
