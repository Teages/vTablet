import 'package:flutter/material.dart';
import 'package:vtablet/configs.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../components/setting_card.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({
    super.key,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...createSettingCard(
                      AppLocalizations.of(context)!.controlAriaTitle,
                      [
                        LabelSlider(
                          label: AppLocalizations.of(context)!
                              .controlAriaScaleLabel,
                          value: Configs.ariaScale.get(),
                          max: 1,
                          min: 0,
                          divisions: 100,
                          onChanged: (newVal) => {
                            setState(() {
                              Configs.ariaScale.set(newVal);
                            })
                          },
                        ),
                        LabelSlider(
                          label: AppLocalizations.of(context)!
                              .controlAriaOffsetXLabel,
                          value: Configs.ariaOffsetX.get(),
                          max: 1,
                          min: -1,
                          divisions: 100,
                          onChanged: (newVal) => {
                            setState(() {
                              Configs.ariaOffsetX.set(newVal);
                            })
                          },
                        ),
                        LabelSlider(
                          label: AppLocalizations.of(context)!
                              .controlAriaOffsetYLabel,
                          value: Configs.ariaOffsetY.get(),
                          max: 1,
                          min: -1,
                          divisions: 100,
                          onChanged: (newVal) => {
                            setState(() {
                              Configs.ariaOffsetY.set(newVal);
                            })
                          },
                        ),
                      ],
                      context,
                    ),
                    ...createSettingCard(
                      AppLocalizations.of(context)!.controlInputTypeTitle,
                      [
                        const InputChoice(),
                        const SizedBox(
                          height: 45,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .controlInputIgnoreClick),
                            Switch(
                              value: Configs.inputIgnoreClick.get(),
                              onChanged: (bool on) {
                                setState(() {
                                  Configs.inputIgnoreClick.set(on);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                      context,
                    ),
                    ...createSettingCard(
                      AppLocalizations.of(context)!.controlOtherTitle,
                      [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .controlPreventSleep),
                            Switch(
                              value: Configs.preventSleep.get(),
                              onChanged: (bool on) {
                                setState(() {
                                  Configs.preventSleep.set(on);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                      context,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class LabelSlider extends StatefulWidget {
  LabelSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  String label;

  double value = 0;
  double min = 0;
  double max = 0;
  int divisions = 0;

  Function(double) onChanged;

  @override
  State<LabelSlider> createState() => _LabelSliderState();
}

class _LabelSliderState extends State<LabelSlider> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Text('${widget.label}: ${widget.value.toStringAsFixed(2)}'),
        Expanded(
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.value.toStringAsFixed(2),
            onChanged: (double value) {
              widget.value = value;
              widget.onChanged(value);
            },
          ),
        )
      ],
    );
  }
}

class ControlDestination extends StatelessWidget {
  const ControlDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.games_outlined),
      selectedIcon: const Icon(Icons.games),
      label: AppLocalizations.of(context)!.controlPageTitle,
    );
  }
}

NavigationRailDestination controlRailDestination(BuildContext context) {
  return NavigationRailDestination(
    icon: const Icon(Icons.games_outlined),
    selectedIcon: const Icon(Icons.games),
    label: Text(AppLocalizations.of(context)!.controlPageTitle),
  );
}

enum InputTypes { pen, touch, mouse }

class InputChoice extends StatefulWidget {
  const InputChoice({super.key});

  @override
  State<InputChoice> createState() => _InputChoiceState();
}

class _InputChoiceState extends State<InputChoice> {
  Set<InputTypes> selection = getSelection();

  static Set<InputTypes> getSelection() {
    Set<InputTypes> ans = <InputTypes>{};
    if (Configs.inputEnablePen.get()) {
      ans.add(InputTypes.pen);
    }
    if (Configs.inputEnableTouch.get()) {
      ans.add(InputTypes.touch);
    }
    if (Configs.inputEnableMouse.get()) {
      ans.add(InputTypes.mouse);
    }
    return ans;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<InputTypes>(
      segments: <ButtonSegment<InputTypes>>[
        ButtonSegment<InputTypes>(
          value: InputTypes.pen,
          label: Text(AppLocalizations.of(context)!.controlInputTypenamePen),
          icon: const Icon(Icons.edit),
        ),
        ButtonSegment<InputTypes>(
          value: InputTypes.touch,
          label: Text(AppLocalizations.of(context)!.controlInputTypenameTouch),
          icon: const Icon(Icons.touch_app),
        ),
        ButtonSegment<InputTypes>(
          value: InputTypes.mouse,
          label: Text(AppLocalizations.of(context)!.controlInputTypenameMouse),
          icon: const Icon(Icons.mouse),
        ),
      ],
      selected: selection,
      onSelectionChanged: (newSelection) {
        setState(() {
          selection = newSelection;
        });
        if (selection.contains(InputTypes.pen)) {
          Configs.inputEnablePen.set(true);
        } else {
          Configs.inputEnablePen.set(false);
        }
        if (selection.contains(InputTypes.touch)) {
          Configs.inputEnableTouch.set(true);
        } else {
          Configs.inputEnableTouch.set(false);
        }
        if (selection.contains(InputTypes.mouse)) {
          Configs.inputEnableMouse.set(true);
        } else {
          Configs.inputEnableMouse.set(false);
        }
      },
      multiSelectionEnabled: true,
    );
  }
}
