// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faculty_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FacultyModel _$FacultyModelFromJson(Map<String, dynamic> json) {
  return _FacultyModel.fromJson(json);
}

/// @nodoc
mixin _$FacultyModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'campus_id')
  String get campusId => throw _privateConstructorUsedError;
  @JsonKey(name: 'dean_id')
  String? get deanId => throw _privateConstructorUsedError;
  String? get deanName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FacultyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FacultyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacultyModelCopyWith<FacultyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacultyModelCopyWith<$Res> {
  factory $FacultyModelCopyWith(
    FacultyModel value,
    $Res Function(FacultyModel) then,
  ) = _$FacultyModelCopyWithImpl<$Res, FacultyModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    @JsonKey(name: 'campus_id') String campusId,
    @JsonKey(name: 'dean_id') String? deanId,
    String? deanName,
    String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$FacultyModelCopyWithImpl<$Res, $Val extends FacultyModel>
    implements $FacultyModelCopyWith<$Res> {
  _$FacultyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FacultyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? campusId = null,
    Object? deanId = freezed,
    Object? deanName = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            campusId: null == campusId
                ? _value.campusId
                : campusId // ignore: cast_nullable_to_non_nullable
                      as String,
            deanId: freezed == deanId
                ? _value.deanId
                : deanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            deanName: freezed == deanName
                ? _value.deanName
                : deanName // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FacultyModelImplCopyWith<$Res>
    implements $FacultyModelCopyWith<$Res> {
  factory _$$FacultyModelImplCopyWith(
    _$FacultyModelImpl value,
    $Res Function(_$FacultyModelImpl) then,
  ) = __$$FacultyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    @JsonKey(name: 'campus_id') String campusId,
    @JsonKey(name: 'dean_id') String? deanId,
    String? deanName,
    String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$FacultyModelImplCopyWithImpl<$Res>
    extends _$FacultyModelCopyWithImpl<$Res, _$FacultyModelImpl>
    implements _$$FacultyModelImplCopyWith<$Res> {
  __$$FacultyModelImplCopyWithImpl(
    _$FacultyModelImpl _value,
    $Res Function(_$FacultyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FacultyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? campusId = null,
    Object? deanId = freezed,
    Object? deanName = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$FacultyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        campusId: null == campusId
            ? _value.campusId
            : campusId // ignore: cast_nullable_to_non_nullable
                  as String,
        deanId: freezed == deanId
            ? _value.deanId
            : deanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        deanName: freezed == deanName
            ? _value.deanName
            : deanName // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FacultyModelImpl implements _FacultyModel {
  const _$FacultyModelImpl({
    required this.id,
    required this.name,
    required this.code,
    @JsonKey(name: 'campus_id') required this.campusId,
    @JsonKey(name: 'dean_id') this.deanId,
    this.deanName,
    this.status = 'active',
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$FacultyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacultyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  @JsonKey(name: 'campus_id')
  final String campusId;
  @override
  @JsonKey(name: 'dean_id')
  final String? deanId;
  @override
  final String? deanName;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'FacultyModel(id: $id, name: $name, code: $code, campusId: $campusId, deanId: $deanId, deanName: $deanName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacultyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.campusId, campusId) ||
                other.campusId == campusId) &&
            (identical(other.deanId, deanId) || other.deanId == deanId) &&
            (identical(other.deanName, deanName) ||
                other.deanName == deanName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    code,
    campusId,
    deanId,
    deanName,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of FacultyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacultyModelImplCopyWith<_$FacultyModelImpl> get copyWith =>
      __$$FacultyModelImplCopyWithImpl<_$FacultyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FacultyModelImplToJson(this);
  }
}

abstract class _FacultyModel implements FacultyModel {
  const factory _FacultyModel({
    required final String id,
    required final String name,
    required final String code,
    @JsonKey(name: 'campus_id') required final String campusId,
    @JsonKey(name: 'dean_id') final String? deanId,
    final String? deanName,
    final String status,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$FacultyModelImpl;

  factory _FacultyModel.fromJson(Map<String, dynamic> json) =
      _$FacultyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get code;
  @override
  @JsonKey(name: 'campus_id')
  String get campusId;
  @override
  @JsonKey(name: 'dean_id')
  String? get deanId;
  @override
  String? get deanName;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of FacultyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacultyModelImplCopyWith<_$FacultyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
