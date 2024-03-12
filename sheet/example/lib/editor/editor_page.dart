import 'package:example/base_scaffold.dart';
import 'package:example/editor/editor_child.dart';
import 'package:example/editor/editor_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sheet/sheet.dart';

const double kAspectRatio = 0.6;
const double kHeight = 200.0;

class SheetConfigurationPage extends StatelessWidget {
  const SheetConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<SheetController>(
            create: (BuildContext context) => SheetController()),
        ChangeNotifierProvider<SheetConfigurationController>(
          create: (BuildContext context) => SheetConfigurationController(),
        ),
      ],
      builder: (BuildContext context, Widget? child) {
        final SheetConfiguration configuration =
            context.watch<SheetConfigurationController>().value;

        return Stack(
          children: <Widget>[
            BaseScaffold(
              title: const Text('Custom Sheet'),
              appBarTrailingButton: TextButton(
                child: const Text('Edit'),
                onPressed: () {
                  context.read<SheetController>().relativeAnimateTo(
                        1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                },
              ),
              sheet: Sheet(
                initialExtent: 400,
                minExtent: configuration.minExtent,
                maxExtent: configuration.maxExtent,
                padding: EdgeInsets.all(configuration.padding ?? 0),
                physics: <SheetPhysics>[
                  if (configuration.bounce) const BouncingSheetPhysics(),
                  if (!configuration.draggable)
                    const NeverDraggableSheetPhysics(),
                ].fold(
                  null,
                  (SheetPhysics? previousValue, SheetPhysics element) =>
                      element.applyTo(previousValue) as SheetPhysics,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    configuration.borderRadius ?? 0,
                  ),
                ),
                elevation: 4,
                child: configuration.type.child(),
              ),
            ),
            Sheet(
              initialExtent: 0,
              minInteractionExtent: 0,
              physics: const NeverDraggableSheetPhysics(),
              fit: SheetFit.expand,
              child: const FilterEditor(),
              controller: context.watch<SheetController>(),
            ),
          ],
        );
      },
    );
  }
}

class FilterEditor extends StatelessWidget {
  const FilterEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final SheetConfigurationController controller =
        context.watch<SheetConfigurationController>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Sheet'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ElevatedButton(
          child: const Text('Close'),
          onPressed: () {
            context.read<SheetController>().relativeAnimateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SectionTitle('Size'),
              ...ListTile.divideTiles(
                context: context,
                tiles: <Widget>[
                  ListTile(
                    title: const Text('Minimun Extent'),
                    trailing: NumTextField(onChanged: (int? value) {
                      controller.value = controller.value.copyWith(
                        minExtent: value?.toDouble(),
                      );
                    }),
                  ),
                  ListTile(
                    title: const Text('Maximun Extent'),
                    trailing: NumTextField(onChanged: (int? value) {
                      controller.value = controller.value.copyWith(
                        maxExtent: value?.toDouble(),
                      );
                    }),
                  ),
                  ListTile(
                    title: const Text('Force expand'),
                    trailing: CupertinoSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      value: controller.value.fit == SheetFit.expand,
                      onChanged: (bool value) {
                        controller.value = controller.value.copyWith(
                          fit: value == true ? SheetFit.expand : SheetFit.loose,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SectionTitle('Appareance'),
              ...ListTile.divideTiles(
                context: context,
                tiles: <Widget>[
                  ListTile(
                    title: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 0),
                      child: Text('Child'),
                    ),
                    contentPadding: EdgeInsets.zero,
                    subtitle: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (final SheetChildType type
                              in SheetChildType.values)
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              width: kHeight * kAspectRatio,
                              height: kHeight,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: controller.value.type == type
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  controller.value = controller.value.copyWith(
                                    type: type,
                                  );
                                },
                                child: IgnorePointer(
                                  child: FittedBox(
                                    child: Container(
                                      width: kHeight * kAspectRatio * 2,
                                      height: kHeight * 2,
                                      child: type.child(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Border Radius'),
                    subtitle: const Text('max 50'),
                    trailing: NumTextField(
                      onChanged: (int? value) {
                        controller.value = controller.value.copyWith(
                          borderRadius: value?.toDouble(),
                        );
                      },
                      maxNumber: 50,
                    ),
                  ),
                  ListTile(
                    title: const Text('Padding'),
                    subtitle: const Text('max 50'),
                    trailing: NumTextField(
                        maxNumber: 50,
                        onChanged: (int? value) {
                          controller.value = controller.value.copyWith(
                            padding: value?.toDouble(),
                          );
                        }),
                  ),
                ],
              ),
              const SectionTitle('Physics'),
              ...ListTile.divideTiles(
                context: context,
                tiles: <Widget>[
                  ListTile(
                    title: const Text('BouncingSheetPhysics'),
                    trailing: CupertinoSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      value: controller.value.bounce,
                      onChanged: (bool value) {
                        controller.value = controller.value.copyWith(
                          bounce: value,
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('NeverDraggableSheetPhysics'),
                    trailing: CupertinoSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      value: !controller.value.draggable,
                      onChanged: (bool value) {
                        controller.value = controller.value.copyWith(
                          draggable: !value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

class NumTextField extends StatelessWidget {
  const NumTextField({super.key, this.onChanged, this.maxNumber = 999});
  final ValueChanged<int?>? onChanged;
  final int maxNumber;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(3),
          NumericalRangeFormatter(min: 0, max: maxNumber.toDouble()),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        keyboardType: TextInputType.number,
        onChanged: (String value) {
          final int? numValue = int.tryParse(value);
          onChanged?.call(numValue);
        },
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          fillColor: Colors.grey[200],
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({required this.min, required this.max});
  final double min;
  final double max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
