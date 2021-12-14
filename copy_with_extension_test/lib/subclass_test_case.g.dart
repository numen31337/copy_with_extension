// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subclass_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

class _BasicBaseClassCopyWithProxy {
  final BasicBaseClass _value;

  _BasicBaseClassCopyWithProxy(this._value);

  BasicBaseClass id(String id) => _value._copyWithValues(id: id);
}

extension BasicBaseClassCopyWith on BasicBaseClass {
  _BasicBaseClassCopyWithProxy get copyWith =>
      _BasicBaseClassCopyWithProxy(this);

  BasicBaseClass _copyWithValues({
    String? id,
  }) {
    return BasicBaseClass(
      id: id ?? this.id,
    );
  }
}

class _BasicBaseSubClassCopyWithProxy<T> {
  final BasicBaseSubClass _value;

  _BasicBaseSubClassCopyWithProxy(this._value);

  BasicBaseSubClass item(T? item) => item == null
      ? _value._copyWithNull(item: true)
      : _value._copyWithValues(item: item);

  BasicBaseSubClass id(String id) => _value._copyWithValues(id: id);
}

extension BasicBaseSubClassCopyWith<T> on BasicBaseSubClass<T> {
  _BasicBaseSubClassCopyWithProxy get copyWith =>
      _BasicBaseSubClassCopyWithProxy<T>(this);

  BasicBaseSubClass<T> _copyWithValues({
    String? id,
    T? item,
  }) {
    return BasicBaseSubClass<T>(
      id: id ?? this.id,
      item: item ?? this.item,
    );
  }

  BasicBaseSubClass<T> _copyWithNull({
    bool item = false,
  }) {
    return BasicBaseSubClass<T>(
      id: id,
      item: item == true ? null : this.item,
    );
  }
}

class _BasicBaseSubClassNamedCopyWithProxy<T> {
  final BasicBaseSubClassNamed _value;

  _BasicBaseSubClassNamedCopyWithProxy(this._value);

  BasicBaseSubClassNamed item(T? item) => item == null
      ? _value._copyWithNull(item: true)
      : _value._copyWithValues(item: item);

  BasicBaseSubClassNamed id(String id) => _value._copyWithValues(id: id);
}

extension BasicBaseSubClassNamedCopyWith<T> on BasicBaseSubClassNamed<T> {
  _BasicBaseSubClassNamedCopyWithProxy get copyWith =>
      _BasicBaseSubClassNamedCopyWithProxy<T>(this);

  BasicBaseSubClassNamed<T> _copyWithValues({
    String? id,
    T? item,
  }) {
    return BasicBaseSubClassNamed<T>._(
      id: id ?? this.id,
      item: item ?? this.item,
    );
  }

  BasicBaseSubClassNamed<T> _copyWithNull({
    bool item = false,
  }) {
    return BasicBaseSubClassNamed<T>._(
      id: id,
      item: item == true ? null : this.item,
    );
  }
}

class _SubClassCopyWithProxy<T, U extends String> {
  final SubClass _value;

  _SubClassCopyWithProxy(this._value);

  SubClass aString(String? aString) => aString == null
      ? _value.copyWithNull(aString: true)
      : _value._copyWithValues(aString: aString);

  SubClass item(T? item) => item == null
      ? _value.copyWithNull(item: true)
      : _value._copyWithValues(item: item);

  SubClass listWithGenericType(List<T>? listWithGenericType) =>
      listWithGenericType == null
          ? _value.copyWithNull(listWithGenericType: true)
          : _value._copyWithValues(listWithGenericType: listWithGenericType);

  SubClass listWithType(List<int>? listWithType) => listWithType == null
      ? _value.copyWithNull(listWithType: true)
      : _value._copyWithValues(listWithType: listWithType);

  SubClass listWithTypedType(List<Iterable<U>?>? listWithTypedType) =>
      listWithTypedType == null
          ? _value.copyWithNull(listWithTypedType: true)
          : _value._copyWithValues(listWithTypedType: listWithTypedType);

  SubClass date(DateTime date) => _value._copyWithValues(date: date);

  SubClass id(String id) => _value._copyWithValues(id: id);
}

extension SubClassCopyWith<T, U extends String> on SubClass<T, U> {
  _SubClassCopyWithProxy get copyWith => _SubClassCopyWithProxy<T, U>(this);

  SubClass<T, U> _copyWithValues({
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
