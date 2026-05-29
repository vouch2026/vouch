// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) {
  return _AnnouncementModel.fromJson(json);
}

/// @nodoc
mixin _$AnnouncementModel {
  String? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_url')
  String? get linkUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_type')
  String get scopeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_id')
  String get scopeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_term_id')
  String get academicTermId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId => throw _privateConstructorUsedError; // Virtual fields
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get authorName => throw _privateConstructorUsedError;

  /// Serializes this AnnouncementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnouncementModelCopyWith<AnnouncementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementModelCopyWith<$Res> {
  factory $AnnouncementModelCopyWith(
    AnnouncementModel value,
    $Res Function(AnnouncementModel) then,
  ) = _$AnnouncementModelCopyWithImpl<$Res, AnnouncementModel>;
  @useResult
  $Res call({
    String? id,
    String title,
    String content,
    String type,
    @JsonKey(name: 'link_url') String? linkUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) String? authorName,
  });
}

/// @nodoc
class _$AnnouncementModelCopyWithImpl<$Res, $Val extends AnnouncementModel>
    implements $AnnouncementModelCopyWith<$Res> {
  _$AnnouncementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? linkUrl = freezed,
    Object? imageUrl = freezed,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? academicTermId = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
    Object? authorName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            linkUrl: freezed == linkUrl
                ? _value.linkUrl
                : linkUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            scopeType: null == scopeType
                ? _value.scopeType
                : scopeType // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeId: null == scopeId
                ? _value.scopeId
                : scopeId // ignore: cast_nullable_to_non_nullable
                      as String,
            academicTermId: null == academicTermId
                ? _value.academicTermId
                : academicTermId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdByUserId: freezed == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorName: freezed == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnouncementModelImplCopyWith<$Res>
    implements $AnnouncementModelCopyWith<$Res> {
  factory _$$AnnouncementModelImplCopyWith(
    _$AnnouncementModelImpl value,
    $Res Function(_$AnnouncementModelImpl) then,
  ) = __$$AnnouncementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String title,
    String content,
    String type,
    @JsonKey(name: 'link_url') String? linkUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) String? authorName,
  });
}

/// @nodoc
class __$$AnnouncementModelImplCopyWithImpl<$Res>
    extends _$AnnouncementModelCopyWithImpl<$Res, _$AnnouncementModelImpl>
    implements _$$AnnouncementModelImplCopyWith<$Res> {
  __$$AnnouncementModelImplCopyWithImpl(
    _$AnnouncementModelImpl _value,
    $Res Function(_$AnnouncementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? linkUrl = freezed,
    Object? imageUrl = freezed,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? academicTermId = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
    Object? authorName = freezed,
  }) {
    return _then(
      _$AnnouncementModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        linkUrl: freezed == linkUrl
            ? _value.linkUrl
            : linkUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        scopeType: null == scopeType
            ? _value.scopeType
            : scopeType // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeId: null == scopeId
            ? _value.scopeId
            : scopeId // ignore: cast_nullable_to_non_nullable
                  as String,
        academicTermId: null == academicTermId
            ? _value.academicTermId
            : academicTermId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdByUserId: freezed == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorName: freezed == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnnouncementModelImpl implements _AnnouncementModel {
  const _$AnnouncementModelImpl({
    this.id,
    required this.title,
    required this.content,
    this.type = 'General',
    @JsonKey(name: 'link_url') this.linkUrl,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'scope_type') required this.scopeType,
    @JsonKey(name: 'scope_id') required this.scopeId,
    @JsonKey(name: 'academic_term_id') required this.academicTermId,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'created_by_user_id') this.createdByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) this.authorName,
  });

  factory _$AnnouncementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnouncementModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey(name: 'link_url')
  final String? linkUrl;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'scope_type')
  final String scopeType;
  @override
  @JsonKey(name: 'scope_id')
  final String scopeId;
  @override
  @JsonKey(name: 'academic_term_id')
  final String academicTermId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'created_by_user_id')
  final String? createdByUserId;
  // Virtual fields
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? authorName;

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, content: $content, type: $type, linkUrl: $linkUrl, imageUrl: $imageUrl, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId, authorName: $authorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.scopeType, scopeType) ||
                other.scopeType == scopeType) &&
            (identical(other.scopeId, scopeId) || other.scopeId == scopeId) &&
            (identical(other.academicTermId, academicTermId) ||
                other.academicTermId == academicTermId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    type,
    linkUrl,
    imageUrl,
    scopeType,
    scopeId,
    academicTermId,
    createdAt,
    updatedAt,
    createdByUserId,
    authorName,
  );

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementModelImplCopyWith<_$AnnouncementModelImpl> get copyWith =>
      __$$AnnouncementModelImplCopyWithImpl<_$AnnouncementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnouncementModelImplToJson(this);
  }
}

abstract class _AnnouncementModel implements AnnouncementModel {
  const factory _AnnouncementModel({
    final String? id,
    required final String title,
    required final String content,
    final String type,
    @JsonKey(name: 'link_url') final String? linkUrl,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'scope_type') required final String scopeType,
    @JsonKey(name: 'scope_id') required final String scopeId,
    @JsonKey(name: 'academic_term_id') required final String academicTermId,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') final String? createdByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false)
    final String? authorName,
  }) = _$AnnouncementModelImpl;

  factory _AnnouncementModel.fromJson(Map<String, dynamic> json) =
      _$AnnouncementModelImpl.fromJson;

  @override
  String? get id;
  @override
  String get title;
  @override
  String get content;
  @override
  String get type;
  @override
  @JsonKey(name: 'link_url')
  String? get linkUrl;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'scope_type')
  String get scopeType;
  @override
  @JsonKey(name: 'scope_id')
  String get scopeId;
  @override
  @JsonKey(name: 'academic_term_id')
  String get academicTermId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId; // Virtual fields
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get authorName;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnouncementModelImplCopyWith<_$AnnouncementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
