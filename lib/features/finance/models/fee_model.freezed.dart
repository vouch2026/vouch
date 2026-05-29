// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeModel _$FeeModelFromJson(Map<String, dynamic> json) {
  return _FeeModel.fromJson(json);
}

/// @nodoc
mixin _$FeeModel {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_type')
  String get scopeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_id')
  String get scopeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_mandatory')
  bool get isMandatory => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime get dueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_term_id')
  String get academicTermId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId => throw _privateConstructorUsedError;

  /// Serializes this FeeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeModelCopyWith<FeeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeModelCopyWith<$Res> {
  factory $FeeModelCopyWith(FeeModel value, $Res Function(FeeModel) then) =
      _$FeeModelCopyWithImpl<$Res, FeeModel>;
  @useResult
  $Res call({
    String? id,
    String name,
    String? description,
    double amount,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'is_mandatory') bool isMandatory,
    @JsonKey(name: 'due_date') DateTime dueDate,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  });
}

/// @nodoc
class _$FeeModelCopyWithImpl<$Res, $Val extends FeeModel>
    implements $FeeModelCopyWith<$Res> {
  _$FeeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? amount = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? isMandatory = null,
    Object? dueDate = null,
    Object? academicTermId = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            scopeType: null == scopeType
                ? _value.scopeType
                : scopeType // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeId: null == scopeId
                ? _value.scopeId
                : scopeId // ignore: cast_nullable_to_non_nullable
                      as String,
            isMandatory: null == isMandatory
                ? _value.isMandatory
                : isMandatory // ignore: cast_nullable_to_non_nullable
                      as bool,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeModelImplCopyWith<$Res>
    implements $FeeModelCopyWith<$Res> {
  factory _$$FeeModelImplCopyWith(
    _$FeeModelImpl value,
    $Res Function(_$FeeModelImpl) then,
  ) = __$$FeeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String name,
    String? description,
    double amount,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'is_mandatory') bool isMandatory,
    @JsonKey(name: 'due_date') DateTime dueDate,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  });
}

/// @nodoc
class __$$FeeModelImplCopyWithImpl<$Res>
    extends _$FeeModelCopyWithImpl<$Res, _$FeeModelImpl>
    implements _$$FeeModelImplCopyWith<$Res> {
  __$$FeeModelImplCopyWithImpl(
    _$FeeModelImpl _value,
    $Res Function(_$FeeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? amount = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? isMandatory = null,
    Object? dueDate = null,
    Object? academicTermId = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
  }) {
    return _then(
      _$FeeModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        scopeType: null == scopeType
            ? _value.scopeType
            : scopeType // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeId: null == scopeId
            ? _value.scopeId
            : scopeId // ignore: cast_nullable_to_non_nullable
                  as String,
        isMandatory: null == isMandatory
            ? _value.isMandatory
            : isMandatory // ignore: cast_nullable_to_non_nullable
                  as bool,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeModelImpl implements _FeeModel {
  const _$FeeModelImpl({
    this.id,
    required this.name,
    this.description,
    required this.amount,
    @JsonKey(name: 'scope_type') required this.scopeType,
    @JsonKey(name: 'scope_id') required this.scopeId,
    @JsonKey(name: 'is_mandatory') this.isMandatory = true,
    @JsonKey(name: 'due_date') required this.dueDate,
    @JsonKey(name: 'academic_term_id') required this.academicTermId,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'created_by_user_id') this.createdByUserId,
  });

  factory _$FeeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double amount;
  @override
  @JsonKey(name: 'scope_type')
  final String scopeType;
  @override
  @JsonKey(name: 'scope_id')
  final String scopeId;
  @override
  @JsonKey(name: 'is_mandatory')
  final bool isMandatory;
  @override
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
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

  @override
  String toString() {
    return 'FeeModel(id: $id, name: $name, description: $description, amount: $amount, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, dueDate: $dueDate, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.scopeType, scopeType) ||
                other.scopeType == scopeType) &&
            (identical(other.scopeId, scopeId) || other.scopeId == scopeId) &&
            (identical(other.isMandatory, isMandatory) ||
                other.isMandatory == isMandatory) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.academicTermId, academicTermId) ||
                other.academicTermId == academicTermId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    amount,
    scopeType,
    scopeId,
    isMandatory,
    dueDate,
    academicTermId,
    createdAt,
    updatedAt,
    createdByUserId,
  );

  /// Create a copy of FeeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeModelImplCopyWith<_$FeeModelImpl> get copyWith =>
      __$$FeeModelImplCopyWithImpl<_$FeeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeModelImplToJson(this);
  }
}

abstract class _FeeModel implements FeeModel {
  const factory _FeeModel({
    final String? id,
    required final String name,
    final String? description,
    required final double amount,
    @JsonKey(name: 'scope_type') required final String scopeType,
    @JsonKey(name: 'scope_id') required final String scopeId,
    @JsonKey(name: 'is_mandatory') final bool isMandatory,
    @JsonKey(name: 'due_date') required final DateTime dueDate,
    @JsonKey(name: 'academic_term_id') required final String academicTermId,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') final String? createdByUserId,
  }) = _$FeeModelImpl;

  factory _FeeModel.fromJson(Map<String, dynamic> json) =
      _$FeeModelImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get amount;
  @override
  @JsonKey(name: 'scope_type')
  String get scopeType;
  @override
  @JsonKey(name: 'scope_id')
  String get scopeId;
  @override
  @JsonKey(name: 'is_mandatory')
  bool get isMandatory;
  @override
  @JsonKey(name: 'due_date')
  DateTime get dueDate;
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
  String? get createdByUserId;

  /// Create a copy of FeeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeModelImplCopyWith<_$FeeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
