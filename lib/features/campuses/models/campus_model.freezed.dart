// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campus_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CampusModel _$CampusModelFromJson(Map<String, dynamic> json) {
  return _CampusModel.fromJson(json);
}

/// @nodoc
mixin _$CampusModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CampusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CampusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampusModelCopyWith<CampusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampusModelCopyWith<$Res> {
  factory $CampusModelCopyWith(
    CampusModel value,
    $Res Function(CampusModel) then,
  ) = _$CampusModelCopyWithImpl<$Res, CampusModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String location,
    String? description,
    String? logoUrl,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CampusModelCopyWithImpl<$Res, $Val extends CampusModel>
    implements $CampusModelCopyWith<$Res> {
  _$CampusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CampusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CampusModelImplCopyWith<$Res>
    implements $CampusModelCopyWith<$Res> {
  factory _$$CampusModelImplCopyWith(
    _$CampusModelImpl value,
    $Res Function(_$CampusModelImpl) then,
  ) = __$$CampusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String location,
    String? description,
    String? logoUrl,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CampusModelImplCopyWithImpl<$Res>
    extends _$CampusModelCopyWithImpl<$Res, _$CampusModelImpl>
    implements _$$CampusModelImplCopyWith<$Res> {
  __$$CampusModelImplCopyWithImpl(
    _$CampusModelImpl _value,
    $Res Function(_$CampusModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CampusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CampusModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CampusModelImpl implements _CampusModel {
  const _$CampusModelImpl({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.logoUrl,
    this.status = 'active',
    this.createdAt,
  });

  factory _$CampusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampusModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String location;
  @override
  final String? description;
  @override
  final String? logoUrl;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CampusModel(id: $id, name: $name, location: $location, description: $description, logoUrl: $logoUrl, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampusModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    location,
    description,
    logoUrl,
    status,
    createdAt,
  );

  /// Create a copy of CampusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampusModelImplCopyWith<_$CampusModelImpl> get copyWith =>
      __$$CampusModelImplCopyWithImpl<_$CampusModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampusModelImplToJson(this);
  }
}

abstract class _CampusModel implements CampusModel {
  const factory _CampusModel({
    required final String id,
    required final String name,
    required final String location,
    final String? description,
    final String? logoUrl,
    final String status,
    final DateTime? createdAt,
  }) = _$CampusModelImpl;

  factory _CampusModel.fromJson(Map<String, dynamic> json) =
      _$CampusModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get location;
  @override
  String? get description;
  @override
  String? get logoUrl;
  @override
  String get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of CampusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampusModelImplCopyWith<_$CampusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
