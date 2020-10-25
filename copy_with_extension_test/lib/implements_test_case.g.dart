// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implements_test_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BasicCopyWith on Basic {
  Basic copyWith({
    String aString,
  }) {
    return Basic(
      aString: aString ?? this.aString,
    );
  }
}

extension WithGenericTypeCopyWith<T> on WithGenericType<T> {
  WithGenericType<T> copyWith({
    T aString,
  }) {
    return WithGenericType<T>(
      aString: aString ?? this.aString,
    );
  }
}

extension WithSpecificTypeCopyWith<String> on WithSpecificType {
  WithSpecificType copyWith({
    String aString,
  }) {
    return WithSpecificType(
      aString: aString ?? this.aString,
    );
  }
}

extension MediaContentCopyWith<MediaContent> on MediaContent {
  MediaContent copyWith({
    DateTime createdOn,
    String id,
    String media,
    String type,
  }) {
    return MediaContent(
      createdOn: createdOn ?? this.createdOn,
      id: id ?? this.id,
      media: media ?? this.media,
      type: type ?? this.type,
    );
  }
}
