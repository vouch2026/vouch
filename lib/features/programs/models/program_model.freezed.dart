// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProgramModel _$ProgramModelFromJson(Map<String, dynamic> json) {
  return _ProgramModel.fromJson(json);
}

/// @nodoc
mixin _$ProgramModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get facultyId => throw _privateConstructorUsedError;
  String? get programHeadId => throw _privateConstructorUsedError;
  String? get programHeadName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProgramModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramModelCopyWith<ProgramModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramModelCopyWith<$Res> {
  factory $ProgramModelCopyWith(
    ProgramModel value,
    $Res Function(ProgramModel) then,
  ) = _$ProgramModelCopyWithImpl<$Res, ProgramModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    String facultyId,
    String? programHeadId,
    String? programHeadName,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ProgramModelCopyWithImpl<$Res, $Val extends ProgramModel>
    implements $ProgramModelCopyWith<$Res> {
  _$ProgramModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? facultyId = null,
    Object? programHeadId = freezed,
    Object? programHeadName = freezed,
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
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            facultyId: null == facultyId
                ? _value.facultyId
                : facultyId // ignore: cast_nullable_to_non_nullable
                      as String,
            programHeadId: freezed == programHeadId
                ? _value.programHeadId
                : programHeadId // ignore: cast_nullable_to_non_nullable
                      as String?,
            programHeadName: freezed == programHeadName
                ? _value.programHeadName
                : programHeadName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ProgramModelImplCopyWith<$Res>
    implements $ProgramModelCopyWith<$Res> {
  factory _$$ProgramModelImplCopyWith(
    _$ProgramModelImpl value,
    $Res Function(_$ProgramModelImpl) then,
  ) = __$$ProgramModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    String facultyId,
    String? programHeadId,
    String? programHeadName,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ProgramModelImplCopyWithImpl<$Res>
    extends _$ProgramModelCopyWithImpl<$Res, _$ProgramModelImpl>
    implements _$$ProgramModelImplCopyWith<$Res> {
  __$$ProgramModelImplCopyWithImpl(
    _$ProgramModelImpl _value,
    $Res Function(_$ProgramModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? facultyId = null,
    Object? programHeadId = freezed,
    Object? programHeadName = freezed,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ProgramModelImpl(
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
        facultyId: null == facultyId
            ? _value.facultyId
            : facultyId // ignore: cast_nullable_to_non_nullable
                  as String,
        programHeadId: freezed == programHeadId
            ? _value.programHeadId
            : programHeadId // ignore: cast_nullable_to_non_nullable
                  as String?,
        programHeadName: freezed == programHeadName
            ? _value.programHeadName
            : programHeadName // ignore: cast_nullable_to_non_nullable
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
class _$ProgramModelImpl implements _ProgramModel {
  const _$ProgramModelImpl({
    required this.id,
    required this.name,
    required this.code,
    required this.facultyId,
    this.programHeadId,
    this.programHeadName,
    this.status = 'active',
    this.createdAt,
  });

  factory _$ProgramModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String facultyId;
  @override
  final String? programHeadId;
  @override
  final String? programHeadName;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ProgramModel(id: $id, name: $name, code: $code, facultyId: $facultyId, programHeadId: $programHeadId, programHeadName: $programHeadName, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.facultyId, facultyId) ||
                other.facultyId == facultyId) &&
            (identical(other.programHeadId, programHeadId) ||
                other.programHeadId == programHeadId) &&
            (identical(other.programHeadName, programHeadName) ||
                other.programHeadName == programHeadName) &&
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
    code,
    facultyId,
    programHeadId,
    programHeadName,
    status,
    createdAt,
  );

  /// Create a copy of ProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramModelImplCopyWith<_$ProgramModelImpl> get copyWith =>
      __$$ProgramModelImplCopyWithImpl<_$ProgramModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramModelImplToJson(this);
  }
}

abstract class _ProgramModel implements ProgramModel {
  const factory _ProgramModel({
    required final String id,
    required final String name,
    required final String code,
    required final String facultyId,
    final String? programHeadId,
    final String? programHeadName,
    final String status,
    final DateTime? createdAt,
  }) = _$ProgramModelImpl;

  factory _ProgramModel.fromJson(Map<String, dynamic> json) =
      _$ProgramModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String get facultyId;
  @override
  String? get programHeadId;
  @override
  String? get programHeadName;
  @override
  String get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of ProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramModelImplCopyWith<_$ProgramModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
