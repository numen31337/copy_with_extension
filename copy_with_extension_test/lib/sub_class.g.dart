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

  SubClass copyWithNull({
    bool aString = false,
    bool date = false,
    bool id = false,
    bool listWithGenericType = false,
    bool listWithType = false,
    bool listWithTypedType = false,
    bool privateField = false,
  }) {
    return SubClass(
      aString: aString == true ? null : this.aString,
      date: date == true ? null : this.date,
      id: id == true ? null : this.id,
      listWithGenericType:
          listWithGenericType == true ? null : this.listWithGenericType,
      listWithType: listWithType == true ? null : this.listWithType,
      listWithTypedType:
          listWithTypedType == true ? null : this.listWithTypedType,
      privateField: privateField == true ? null : this.privateField,
    );
  }
}
