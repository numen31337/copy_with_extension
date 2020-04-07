// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_type, always_specify_types

extension BasicBaseClassCopyWithExtension on BasicBaseClass {
  BasicBaseClass copyWith({
    String id,
  }) {
    return BasicBaseClass(
      id: id ?? this.id,
    );
  }
}

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_type, always_specify_types

extension SubClassCopyWithExtension on SubClass {
  SubClass copyWith({
    String aString,
    DateTime date,
    String id,
    List listWithGenericType,
    List listWithType,
    List listWithTypedType,
    String privateField,
  }) {
    return SubClass(
      aString: aString ?? this.aString,
      date: date ?? this.date,
      id: id ?? this.id,
      listWithGenericType: listWithGenericType ?? this.listWithGenericType,
      listWithType: listWithType ?? this.listWithType,
      listWithTypedType: listWithTypedType ?? this.listWithTypedType,
      privateField: privateField ?? this.privateField,
    );
  }
}
