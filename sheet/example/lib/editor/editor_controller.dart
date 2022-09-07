import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

import 'editor_child.dart';

class SheetConfigurationController extends ValueNotifier<SheetConfiguration> {
  SheetConfigurationController() : super(const SheetConfiguration());
}

class SheetConfiguration extends Equatable {
  const SheetConfiguration({
    this.minExtent,
    this.maxExtent,
    this.type = SheetChildType.scroll,
    this.borderRadius,
    this.bounce = true,
    this.fit = SheetFit.loose,
    this.childrenCount,
    this.padding,
    this.stops = const <double>[],
    this.draggable = true,
  });

  final double? minExtent;
  final double? maxExtent;
  final double? borderRadius;
  final double? padding;
  final SheetChildType type;
  final bool bounce;
  final SheetFit fit;
  final int? childrenCount;
  final List<double> stops;
  final bool draggable;

  @override
  List<Object?> get props => <Object?>[
        minExtent,
        maxExtent,
        borderRadius,
        type,
        bounce,
        fit,
        childrenCount,
        padding,
        stops,
        draggable,
      ];

  SheetConfiguration copyWith({
    double? minExtent,
    double? maxExtent,
    SheetChildType? type,
    double? borderRadius,
    bool? bounce,
    SheetFit? fit,
    int? childrenCount,
    double? padding,
    List<double>? stops,
    bool? draggable,
  }) {
    return SheetConfiguration(
      minExtent: minExtent ?? this.minExtent,
      maxExtent: maxExtent ?? this.maxExtent,
      type: type ?? this.type,
      borderRadius: borderRadius ?? this.borderRadius,
      bounce: bounce ?? this.bounce,
      fit: fit ?? this.fit,
      childrenCount: childrenCount ?? this.childrenCount,
      padding: padding ?? this.padding,
      stops: stops ?? this.stops,
      draggable: draggable ?? this.draggable,
    );
  }
}
