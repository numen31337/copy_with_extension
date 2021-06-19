// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subclass_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BasicBaseClassCopyWith on BasicBaseClass {
  BasicBaseClass copyWith({
    String? id,
  }) {
    return BasicBaseClass(
      id: id ?? this.id,
    );
  }
}

extension BasicBaseSubClassCopyWith<T> on BasicBaseSubClass<T> {
  BasicBaseSubClass<T> copyWith({
    String? id,
    T? item,
  }) {
    return BasicBaseSubClass<T>(
      id: id ?? this.id,
      item: item ?? this.item,
    );
  }
}

extension SubClassCopyWith<T, U extends String> on SubClass<T, U> {
  SubClass<T, U> copyWith({
    String? aString,
    DateTime? date,
    String? id,
    T? item,
    List<T>? listWithGenericType,
    List<int>? listWithType,
    List<Iterable<U>?>? listWithTypedType,
  }) {
    return SubClass<T, U>(
      aString: aString ?? this.aString,
      date: date ?? this.date,
      id: id ?? this.id,
      item: item ?? this.item,
      listWithGenericType: listWithGenericType ?? this.listWithGenericType,
      listWithType: listWithType ?? this.listWithType,
      listWithTypedType: listWithTypedType ?? this.listWithTypedType,
      privateField: privateField,
    );
  }

  SubClass<T, U> copyWithNull({
    bool aString = false,
    bool item = false,
    bool listWithGenericType = false,
    bool listWithType = false,
    bool listWithTypedType = false,
  }) {
    return SubClass<T, U>(
      aString: aString == true ? null : this.aString,
      date: date,
      id: id,
      item: item == true ? null : this.item,
      listWithGenericType:
          listWithGenericType == true ? null : this.listWithGenericType,
      listWithType: listWithType == true ? null : this.listWithType,
      listWithTypedType:
          listWithTypedType == true ? null : this.listWithTypedType,
      privateField: privateField,
    );
  }
}
