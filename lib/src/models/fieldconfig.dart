import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FieldConfig extends Equatable {
  const FieldConfig({
    required this.label,
    required this.type,
    this.hintText,
    this.value,
    this.isRequired = false,
    this.minLength,
    this.maxLength,
    this.options,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.allowedFileTypes,
    this.min,
    this.max,
    this.initialValue,
    this.divisions,
    this.isInteger,
    this.use24HourFormat,
    this.maxLines,
    this.minLines,
    this.isReadOnly,
    this.hidden,
    this.isCurrency,
    this.isMultiSelect,
    this.isCancellable,
  });

  final String label;
  final String type;
  final String? hintText;
  final dynamic value;
  final bool isRequired;
  final int? minLength;
  final int? maxLength;
  final List<String>? options;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final List<String>? allowedFileTypes;
  final double? min;
  final double? max;
  final double? initialValue;
  final int? divisions;
  final bool? isInteger;
  final bool? use24HourFormat;
  final int? maxLines;
  final int? minLines;
  final bool? isReadOnly;
  final bool? hidden;
  final bool? isCurrency;
  final bool? isMultiSelect;
  final bool? isCancellable;

  FieldConfig copyWith({
    String? label,
    String? type,
    String? hintText,
    String? value,
    bool? isRequired,
    int? minLength,
    int? maxLength,
    List<String>? options,
    TextInputType? keyboardType,
    bool? obscureText,
    IconData? prefixIcon,
    List<String>? allowedFileTypes,
    double? min,
    double? max,
    double? initialValue,
    int? divisions,
    bool? isInteger,
    bool? use24HourFormat,
    int? maxLines,
    int? minLines,
    bool? isReadOnly,
    bool? hidden,
    bool? isCurrency,
    bool? isMultiSelect,
    bool? isCancellable,
  }) {
    return FieldConfig(
      label: label ?? this.label,
      type: type ?? this.type,
      hintText: hintText ?? this.hintText,
      value: value ?? this.value,
      isRequired: isRequired ?? this.isRequired,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      options: options ?? this.options,
      keyboardType: keyboardType ?? this.keyboardType,
      obscureText: obscureText ?? this.obscureText,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      min: min ?? this.min,
      max: max ?? this.max,
      initialValue: initialValue ?? this.initialValue,
      divisions: divisions ?? this.divisions,
      isInteger: isInteger ?? this.isInteger,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      hidden: hidden ?? this.hidden,
      isCurrency: isCurrency ?? this.isCurrency,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      isCancellable: isCancellable ?? this.isCancellable,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        label,
        type,
        hintText,
        value,
        isRequired,
        minLength,
        maxLength,
        options,
        keyboardType,
        obscureText,
        prefixIcon,
        allowedFileTypes,
        min,
        max,
        initialValue,
        divisions,
        isInteger,
        use24HourFormat,
        maxLines,
        minLines,
        isReadOnly,
        hidden,
        isCurrency,
        isMultiSelect,
        isCancellable,
      ];
}
