import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'package:vtablet/configs.dart';

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
                    ...SettingCard(
                      "输入区域",
                      [
                        LabelSlider(
                          label: "缩放",
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
                          label: "X 偏移",
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
                          label: "Y 偏移",
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
                    ...SettingCard(
                      "输入类型",
                      [
                        InputChoice(),
                        const SizedBox(
                          height: 45,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('忽略压力信息'),
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
                    ...SettingCard(
                      "其他设置",
                      [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('阻止手机/平板休眠'),
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
    return const NavigationDestination(
      icon: Icon(Icons.games_outlined),
      selectedIcon: Icon(Icons.games),
      label: '控制',
    );
  }
}

NavigationRailDestination ControlRailDestination() {
  return const NavigationRailDestination(
    icon: Icon(Icons.games_outlined),
    selectedIcon: Icon(Icons.games),
    label: Text('控制'),
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
      segments: const <ButtonSegment<InputTypes>>[
        ButtonSegment<InputTypes>(
          value: InputTypes.pen,
          label: Text('笔'),
          icon: Icon(Icons.edit),
        ),
        ButtonSegment<InputTypes>(
          value: InputTypes.touch,
          label: Text('触摸'),
          icon: Icon(Icons.touch_app),
        ),
        ButtonSegment<InputTypes>(
          value: InputTypes.mouse,
          label: Text('鼠标'),
          icon: Icon(Icons.mouse),
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
