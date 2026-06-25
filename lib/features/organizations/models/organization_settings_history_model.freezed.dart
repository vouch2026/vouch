// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_settings_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationSettingsHistoryModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'setting_key') String get settingKey;@JsonKey(name: 'old_value') dynamic get oldValue;@JsonKey(name: 'new_value') dynamic get newValue;@JsonKey(name: 'changed_by_user_id') String? get changedByUserId;@JsonKey(name: 'academic_term_id') String? get academicTermId;@JsonKey(name: 'changed_at') DateTime? get changedAt;
/// Create a copy of OrganizationSettingsHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationSettingsHistoryModelCopyWith<OrganizationSettingsHistoryModel> get copyWith => _$OrganizationSettingsHistoryModelCopyWithImpl<OrganizationSettingsHistoryModel>(this as OrganizationSettingsHistoryModel, _$identity);

  /// Serializes this OrganizationSettingsHistoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationSettingsHistoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.settingKey, settingKey) || other.settingKey == settingKey)&&const DeepCollectionEquality().equals(other.oldValue, oldValue)&&const DeepCollectionEquality().equals(other.newValue, newValue)&&(identical(other.changedByUserId, changedByUserId) || other.changedByUserId == changedByUserId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,settingKey,const DeepCollectionEquality().hash(oldValue),const DeepCollectionEquality().hash(newValue),changedByUserId,academicTermId,changedAt);

@override
String toString() {
  return 'OrganizationSettingsHistoryModel(id: $id, organizationId: $organizationId, settingKey: $settingKey, oldValue: $oldValue, newValue: $newValue, changedByUserId: $changedByUserId, academicTermId: $academicTermId, changedAt: $changedAt)';
}


}

/// @nodoc
abstract mixin class $OrganizationSettingsHistoryModelCopyWith<$Res>  {
  factory $OrganizationSettingsHistoryModelCopyWith(OrganizationSettingsHistoryModel value, $Res Function(OrganizationSettingsHistoryModel) _then) = _$OrganizationSettingsHistoryModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'setting_key') String settingKey,@JsonKey(name: 'old_value') dynamic oldValue,@JsonKey(name: 'new_value') dynamic newValue,@JsonKey(name: 'changed_by_user_id') String? changedByUserId,@JsonKey(name: 'academic_term_id') String? academicTermId,@JsonKey(name: 'changed_at') DateTime? changedAt
});




}
/// @nodoc
class _$OrganizationSettingsHistoryModelCopyWithImpl<$Res>
    implements $OrganizationSettingsHistoryModelCopyWith<$Res> {
  _$OrganizationSettingsHistoryModelCopyWithImpl(this._self, this._then);

  final OrganizationSettingsHistoryModel _self;
  final $Res Function(OrganizationSettingsHistoryModel) _then;

/// Create a copy of OrganizationSettingsHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? settingKey = null,Object? oldValue = freezed,Object? newValue = freezed,Object? changedByUserId = freezed,Object? academicTermId = freezed,Object? changedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,settingKey: null == settingKey ? _self.settingKey : settingKey // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as dynamic,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as dynamic,changedByUserId: freezed == changedByUserId ? _self.changedByUserId : changedByUserId // ignore: cast_nullable_to_non_nullable
as String?,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationSettingsHistoryModel].
extension OrganizationSettingsHistoryModelPatterns on OrganizationSettingsHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationSettingsHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationSettingsHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationSettingsHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'setting_key')  String settingKey, @JsonKey(name: 'old_value')  dynamic oldValue, @JsonKey(name: 'new_value')  dynamic newValue, @JsonKey(name: 'changed_by_user_id')  String? changedByUserId, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'changed_at')  DateTime? changedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.settingKey,_that.oldValue,_that.newValue,_that.changedByUserId,_that.academicTermId,_that.changedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'setting_key')  String settingKey, @JsonKey(name: 'old_value')  dynamic oldValue, @JsonKey(name: 'new_value')  dynamic newValue, @JsonKey(name: 'changed_by_user_id')  String? changedByUserId, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'changed_at')  DateTime? changedAt)  $default,) {final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel():
return $default(_that.id,_that.organizationId,_that.settingKey,_that.oldValue,_that.newValue,_that.changedByUserId,_that.academicTermId,_that.changedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'setting_key')  String settingKey, @JsonKey(name: 'old_value')  dynamic oldValue, @JsonKey(name: 'new_value')  dynamic newValue, @JsonKey(name: 'changed_by_user_id')  String? changedByUserId, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'changed_at')  DateTime? changedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationSettingsHistoryModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.settingKey,_that.oldValue,_that.newValue,_that.changedByUserId,_that.academicTermId,_that.changedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationSettingsHistoryModel implements OrganizationSettingsHistoryModel {
  const _OrganizationSettingsHistoryModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'setting_key') required this.settingKey, @JsonKey(name: 'old_value') this.oldValue, @JsonKey(name: 'new_value') this.newValue, @JsonKey(name: 'changed_by_user_id') this.changedByUserId, @JsonKey(name: 'academic_term_id') this.academicTermId, @JsonKey(name: 'changed_at') this.changedAt});
  factory _OrganizationSettingsHistoryModel.fromJson(Map<String, dynamic> json) => _$OrganizationSettingsHistoryModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'setting_key') final  String settingKey;
@override@JsonKey(name: 'old_value') final  dynamic oldValue;
@override@JsonKey(name: 'new_value') final  dynamic newValue;
@override@JsonKey(name: 'changed_by_user_id') final  String? changedByUserId;
@override@JsonKey(name: 'academic_term_id') final  String? academicTermId;
@override@JsonKey(name: 'changed_at') final  DateTime? changedAt;

/// Create a copy of OrganizationSettingsHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationSettingsHistoryModelCopyWith<_OrganizationSettingsHistoryModel> get copyWith => __$OrganizationSettingsHistoryModelCopyWithImpl<_OrganizationSettingsHistoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationSettingsHistoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationSettingsHistoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.settingKey, settingKey) || other.settingKey == settingKey)&&const DeepCollectionEquality().equals(other.oldValue, oldValue)&&const DeepCollectionEquality().equals(other.newValue, newValue)&&(identical(other.changedByUserId, changedByUserId) || other.changedByUserId == changedByUserId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,settingKey,const DeepCollectionEquality().hash(oldValue),const DeepCollectionEquality().hash(newValue),changedByUserId,academicTermId,changedAt);

@override
String toString() {
  return 'OrganizationSettingsHistoryModel(id: $id, organizationId: $organizationId, settingKey: $settingKey, oldValue: $oldValue, newValue: $newValue, changedByUserId: $changedByUserId, academicTermId: $academicTermId, changedAt: $changedAt)';
}


}

/// @nodoc
abstract mixin class _$OrganizationSettingsHistoryModelCopyWith<$Res> implements $OrganizationSettingsHistoryModelCopyWith<$Res> {
  factory _$OrganizationSettingsHistoryModelCopyWith(_OrganizationSettingsHistoryModel value, $Res Function(_OrganizationSettingsHistoryModel) _then) = __$OrganizationSettingsHistoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'setting_key') String settingKey,@JsonKey(name: 'old_value') dynamic oldValue,@JsonKey(name: 'new_value') dynamic newValue,@JsonKey(name: 'changed_by_user_id') String? changedByUserId,@JsonKey(name: 'academic_term_id') String? academicTermId,@JsonKey(name: 'changed_at') DateTime? changedAt
});




}
/// @nodoc
class __$OrganizationSettingsHistoryModelCopyWithImpl<$Res>
    implements _$OrganizationSettingsHistoryModelCopyWith<$Res> {
  __$OrganizationSettingsHistoryModelCopyWithImpl(this._self, this._then);

  final _OrganizationSettingsHistoryModel _self;
  final $Res Function(_OrganizationSettingsHistoryModel) _then;

/// Create a copy of OrganizationSettingsHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? settingKey = null,Object? oldValue = freezed,Object? newValue = freezed,Object? changedByUserId = freezed,Object? academicTermId = freezed,Object? changedAt = freezed,}) {
  return _then(_OrganizationSettingsHistoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,settingKey: null == settingKey ? _self.settingKey : settingKey // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as dynamic,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as dynamic,changedByUserId: freezed == changedByUserId ? _self.changedByUserId : changedByUserId // ignore: cast_nullable_to_non_nullable
as String?,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
