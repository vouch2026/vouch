// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeeModel {

 String? get id; String get name; String? get description; double get amount;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String get scopeId;@JsonKey(name: 'is_mandatory') bool get isMandatory;@JsonKey(name: 'due_date') DateTime get dueDate;@JsonKey(name: 'academic_term_id') String get academicTermId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'created_by_user_id') String? get createdByUserId;
/// Create a copy of FeeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeeModelCopyWith<FeeModel> get copyWith => _$FeeModelCopyWithImpl<FeeModel>(this as FeeModel, _$identity);

  /// Serializes this FeeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,amount,scopeType,scopeId,isMandatory,dueDate,academicTermId,createdAt,updatedAt,createdByUserId);

@override
String toString() {
  return 'FeeModel(id: $id, name: $name, description: $description, amount: $amount, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, dueDate: $dueDate, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
}


}

/// @nodoc
abstract mixin class $FeeModelCopyWith<$Res>  {
  factory $FeeModelCopyWith(FeeModel value, $Res Function(FeeModel) _then) = _$FeeModelCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String? description, double amount,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'is_mandatory') bool isMandatory,@JsonKey(name: 'due_date') DateTime dueDate,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId
});




}
/// @nodoc
class _$FeeModelCopyWithImpl<$Res>
    implements $FeeModelCopyWith<$Res> {
  _$FeeModelCopyWithImpl(this._self, this._then);

  final FeeModel _self;
  final $Res Function(FeeModel) _then;

/// Create a copy of FeeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? description = freezed,Object? amount = null,Object? scopeType = null,Object? scopeId = null,Object? isMandatory = null,Object? dueDate = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as bool,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeeModel].
extension FeeModelPatterns on FeeModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeeModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeeModel value)  $default,){
final _that = this;
switch (_that) {
case _FeeModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeeModel value)?  $default,){
final _that = this;
switch (_that) {
case _FeeModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String? description,  double amount, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'due_date')  DateTime dueDate, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.amount,_that.scopeType,_that.scopeId,_that.isMandatory,_that.dueDate,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String? description,  double amount, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'due_date')  DateTime dueDate, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)  $default,) {final _that = this;
switch (_that) {
case _FeeModel():
return $default(_that.id,_that.name,_that.description,_that.amount,_that.scopeType,_that.scopeId,_that.isMandatory,_that.dueDate,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String? description,  double amount, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'due_date')  DateTime dueDate, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)?  $default,) {final _that = this;
switch (_that) {
case _FeeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.amount,_that.scopeType,_that.scopeId,_that.isMandatory,_that.dueDate,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeeModel implements FeeModel {
  const _FeeModel({this.id, required this.name, this.description, required this.amount, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') required this.scopeId, @JsonKey(name: 'is_mandatory') this.isMandatory = true, @JsonKey(name: 'due_date') required this.dueDate, @JsonKey(name: 'academic_term_id') required this.academicTermId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'created_by_user_id') this.createdByUserId});
  factory _FeeModel.fromJson(Map<String, dynamic> json) => _$FeeModelFromJson(json);

@override final  String? id;
@override final  String name;
@override final  String? description;
@override final  double amount;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String scopeId;
@override@JsonKey(name: 'is_mandatory') final  bool isMandatory;
@override@JsonKey(name: 'due_date') final  DateTime dueDate;
@override@JsonKey(name: 'academic_term_id') final  String academicTermId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'created_by_user_id') final  String? createdByUserId;

/// Create a copy of FeeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeeModelCopyWith<_FeeModel> get copyWith => __$FeeModelCopyWithImpl<_FeeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,amount,scopeType,scopeId,isMandatory,dueDate,academicTermId,createdAt,updatedAt,createdByUserId);

@override
String toString() {
  return 'FeeModel(id: $id, name: $name, description: $description, amount: $amount, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, dueDate: $dueDate, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
}


}

/// @nodoc
abstract mixin class _$FeeModelCopyWith<$Res> implements $FeeModelCopyWith<$Res> {
  factory _$FeeModelCopyWith(_FeeModel value, $Res Function(_FeeModel) _then) = __$FeeModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String? description, double amount,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'is_mandatory') bool isMandatory,@JsonKey(name: 'due_date') DateTime dueDate,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId
});




}
/// @nodoc
class __$FeeModelCopyWithImpl<$Res>
    implements _$FeeModelCopyWith<$Res> {
  __$FeeModelCopyWithImpl(this._self, this._then);

  final _FeeModel _self;
  final $Res Function(_FeeModel) _then;

/// Create a copy of FeeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? description = freezed,Object? amount = null,Object? scopeType = null,Object? scopeId = null,Object? isMandatory = null,Object? dueDate = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,}) {
  return _then(_FeeModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as bool,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
