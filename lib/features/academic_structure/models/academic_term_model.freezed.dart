// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academic_term_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AcademicTermModel _$AcademicTermModelFromJson(Map<String, dynamic> json) {
  return _AcademicTermModel.fromJson(json);
}

/// @nodoc
mixin _$AcademicTermModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String get academicYear => throw _privateConstructorUsedError;
  String get semester => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AcademicTermModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcademicTermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademicTermModelCopyWith<AcademicTermModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademicTermModelCopyWith<$Res> {
  factory $AcademicTermModelCopyWith(
    AcademicTermModel value,
    $Res Function(AcademicTermModel) then,
  ) = _$AcademicTermModelCopyWithImpl<$Res, AcademicTermModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'academic_year') String academicYear,
    String semester,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$AcademicTermModelCopyWithImpl<$Res, $Val extends AcademicTermModel>
    implements $AcademicTermModelCopyWith<$Res> {
  _$AcademicTermModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcademicTermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? academicYear = null,
    Object? semester = null,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            semester: null == semester
                ? _value.semester
                : semester // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$AcademicTermModelImplCopyWith<$Res>
    implements $AcademicTermModelCopyWith<$Res> {
  factory _$$AcademicTermModelImplCopyWith(
    _$AcademicTermModelImpl value,
    $Res Function(_$AcademicTermModelImpl) then,
  ) = __$$AcademicTermModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'academic_year') String academicYear,
    String semester,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$AcademicTermModelImplCopyWithImpl<$Res>
    extends _$AcademicTermModelCopyWithImpl<$Res, _$AcademicTermModelImpl>
    implements _$$AcademicTermModelImplCopyWith<$Res> {
  __$$AcademicTermModelImplCopyWithImpl(
    _$AcademicTermModelImpl _value,
    $Res Function(_$AcademicTermModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AcademicTermModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? academicYear = null,
    Object? semester = null,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AcademicTermModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        semester: null == semester
            ? _value.semester
            : semester // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$AcademicTermModelImpl implements _AcademicTermModel {
  const _$AcademicTermModelImpl({
    required this.id,
    @JsonKey(name: 'academic_year') required this.academicYear,
    required this.semester,
    @JsonKey(name: 'is_active') this.isActive = false,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$AcademicTermModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcademicTermModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'academic_year')
  final String academicYear;
  @override
  final String semester;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AcademicTermModel(id: $id, academicYear: $academicYear, semester: $semester, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademicTermModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.semester, semester) ||
                other.semester == semester) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, academicYear, semester, isActive, createdAt);

  /// Create a copy of AcademicTermModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademicTermModelImplCopyWith<_$AcademicTermModelImpl> get copyWith =>
      __$$AcademicTermModelImplCopyWithImpl<_$AcademicTermModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AcademicTermModelImplToJson(this);
  }
}

abstract class _AcademicTermModel implements AcademicTermModel {
  const factory _AcademicTermModel({
    required final String id,
    @JsonKey(name: 'academic_year') required final String academicYear,
    required final String semester,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$AcademicTermModelImpl;

  factory _AcademicTermModel.fromJson(Map<String, dynamic> json) =
      _$AcademicTermModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'academic_year')
  String get academicYear;
  @override
  String get semester;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of AcademicTermModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademicTermModelImplCopyWith<_$AcademicTermModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
