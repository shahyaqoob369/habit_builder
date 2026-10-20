import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_sheet.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Opens the time picker; returns the chosen time, or null on Cancel.
Future<ReminderTime?> showTimePickerSheet(
  BuildContext context, {
  ReminderTime initial = const ReminderTime(9, 0),
}) {
  return showAppSheet<ReminderTime>(
    context: context,
    builder: (_) => TimePickerSheet(initial: initial),
  );
}

/// Time picker (Figma "Homepage – Set Time"): Cancel · Add Reminders ·
/// Save, hour and minute wheels, and the am / pm switch along the bottom.
class TimePickerSheet extends StatefulWidget {
  const TimePickerSheet({required this.initial, super.key});

  final ReminderTime initial;

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late int _hour = (widget.initial.hour + 11) % 12 + 1; // 1–12
  late int _minute = widget.initial.minute;
  late bool _pm = widget.initial.hour >= 12;

  ReminderTime get _value => ReminderTime(_hour % 12 + (_pm ? 12 : 0), _minute);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(l10n.timePickerTitle, style: AppTextStyles.title),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _SheetAction(
                    label: l10n.cancel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _SheetAction(
                    label: l10n.save,
                    onTap: () => Navigator.of(context).pop(_value),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 39),
        SizedBox(
          height: _Wheel.extent * 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Wheel(
                count: 12,
                initial: _hour - 1,
                label: (i) => '${i + 1}'.padLeft(2, '0'),
                semanticLabel: l10n.timePickerHours,
                onChanged: (i) => setState(() => _hour = i + 1),
              ),
              const SizedBox(
                width: 99,
                child: Text(
                  ':',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pickerSelected,
                ),
              ),
              _Wheel(
                count: 60,
                initial: _minute,
                label: (i) => '$i'.padLeft(2, '0'),
                semanticLabel: l10n.timePickerMinutes,
                onChanged: (i) => setState(() => _minute = i),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Divider(),
        Row(
          children: [
            for (final pm in [false, true])
              Expanded(
                child: Semantics(
                  selected: _pm == pm,
                  button: true,
                  child: InkWell(
                    onTap: () => setState(() => _pm = pm),
                    child: Container(
                      height: 60 + (bottom > 34 ? bottom - 34 : 0),
                      padding: const EdgeInsets.only(top: 18),
                      alignment: Alignment.topCenter,
                      color: _pm == pm ? colors.primary : colors.background,
                      child: Text(
                        pm ? l10n.timePm : l10n.timeAm,
                        style: _pm == pm
                            ? AppTextStyles.periodSelected
                            : AppTextStyles.period.copyWith(
                                color: colors.primary,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: context.colors.primaryDark,
        textStyle: AppTextStyles.lead.copyWith(height: 32 / 17),
        padding: const EdgeInsets.symmetric(horizontal: 22),
      ),
      child: Text(label),
    );
  }
}

/// A flat, looping number wheel: the middle value large and bold, its
/// neighbours smaller and fading out (Figma "Set Time").
class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.count,
    required this.initial,
    required this.label,
    required this.semanticLabel,
    required this.onChanged,
  });

  static const extent = 48.0;

  final int count;
  final int initial;
  final String Function(int index) label;
  final String semanticLabel;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final _controller = FixedExtentScrollController(
    initialItem: widget.initial,
  );
  late int _selected = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: widget.semanticLabel,
      value: widget.label(_selected),
      child: SizedBox(
        width: 48,
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: _Wheel.extent,
          diameterRatio: 1000,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) {
            final index = i % widget.count;
            setState(() => _selected = index);
            widget.onChanged(index);
          },
          childDelegate: ListWheelChildLoopingListDelegate(
            children: [
              for (var i = 0; i < widget.count; i++)
                Center(
                  child: Text(
                    widget.label(i),
                    style: _style(i, colors.textPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _style(int index, Color color) {
    final raw = (index - _selected).abs();
    final distance = raw > widget.count / 2 ? widget.count - raw : raw;
    return switch (distance) {
      0 => AppTextStyles.pickerSelected.copyWith(color: color),
      1 => AppTextStyles.pickerOption.copyWith(
        color: color.withValues(alpha: 0.5),
        fontWeight: FontWeight.w700,
      ),
      _ => AppTextStyles.pickerOption.copyWith(
        color: color.withValues(alpha: 0.2),
      ),
    };
  }
}
