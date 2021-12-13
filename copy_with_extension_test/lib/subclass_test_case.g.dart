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

extension BasicBaseSubClassNamedCopyWith<T> on BasicBaseSubClassNamed<T> {
  BasicBaseSubClassNamed<T> copyWith({
    String? id,
    T? item,
  }) {
    return BasicBaseSubClassNamed<T>._(
      id: id ?? this.id,
      item: item ?? this.item,
    );
  }
}

class _SubClassCopyWithProxy<T, U extends String> {
  final SubClass _value;

  _SubClassCopyWithProxy(this._value);

  SubClass aString(String? aString) => aString == null
      ? _value.copyWithNull(aString: true)
      : _value.copyWith(aString: aString);

  SubClass item(T? item) => item == null
      ? _value.copyWithNull(item: true)
      : _value.copyWith(item: item);

  SubClass listWithGenericType(List<T>? listWithGenericType) =>
      listWithGenericType == null
          ? _value.copyWithNull(listWithGenericType: true)
          : _value.copyWith(listWithGenericType: listWithGenericType);

  SubClass listWithType(List<int>? listWithType) => listWithType == null
      ? _value.copyWithNull(listWithType: true)
      : _value.copyWith(listWithType: listWithType);

  SubClass listWithTypedType(List<Iterable<U>?>? listWithTypedType) =>
      listWithTypedType == null
          ? _value.copyWithNull(listWithTypedType: true)
          : _value.copyWith(listWithTypedType: listWithTypedType);

  SubClass date(DateTime date) => _value.copyWith(date: date);

  SubClass id(String id) => _value.copyWith(id: id);
}

extension SubClassCopyWith<T, U extends String> on SubClass<T, U> {
  _SubClassCopyWithProxy get copyWithField =>
      _SubClassCopyWithProxy<T, U>(this);

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
