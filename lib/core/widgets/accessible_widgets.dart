import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool outlined;

  const AccessibleButton({
    super.key,
    required this.label,
    this.hint = '',
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
    this.backgroundColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return Semantics(
        label: label,
        hint: hint,
        button: true,
        enabled: enabled && !isLoading,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled && !isLoading ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 12),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled && !isLoading,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 12),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;
  final Widget? leading;

  const AccessibleCard({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child ??
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (value != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              value!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class AccessibleSwitch extends StatelessWidget {
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AccessibleSwitch({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint ?? (value ? 'Tap to turn off' : 'Tap to turn on'),
      toggled: value,
      child: SwitchListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class AccessibleSlider extends StatelessWidget {
  final String label;
  final String? hint;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? valueFormatter;

  const AccessibleSlider({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = valueFormatter?.call(value) ?? value.toStringAsFixed(1);

    return Semantics(
      label: '$label: $formattedValue',
      hint: hint ?? 'Adjust slider to change value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                formattedValue,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class AccessibleListTile extends StatelessWidget {
  final String label;
  final String? hint;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final EdgeInsetsGeometry? contentPadding;

  const AccessibleListTile({
    super.key,
    required this.label,
    this.hint,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      selected: selected,
      child: ListTile(
        leading: leading,
        trailing: trailing,
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : null,
      ),
    );
  }
}

class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final bool filled;

  const AccessibleIcon({
    super.key,
    required this.icon,
    required this.label,
    this.hint,
    this.onTap,
    this.size = 48,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class AccessibleDropdownField<T extends Enum> extends StatelessWidget {
  final String label;
  final String? hint;
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;

  const AccessibleDropdownField({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: itemLabel(value),
      hint: hint ?? 'Tap to change selection',
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: DropdownButton<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(itemLabel(e)),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
        ),
      ),
    );
  }
}

class ScreenReaderAnnouncer extends WidgetLocalizations {
  const ScreenReaderAnnouncer();

  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

class AnimatedCounter extends StatelessWidget {
  final int count;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: count - 1, end: count),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style ?? Theme.of(context).textTheme.headlineLarge,
        );
      },
    );
  }
}
