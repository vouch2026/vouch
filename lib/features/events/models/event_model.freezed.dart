// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String? get id; String get name;@JsonKey(name: 'event_date') DateTime get eventDate;@JsonKey(name: 'short_description') String? get shortDescription;@JsonKey(name: 'full_description') String? get fullDescription;@JsonKey(name: 'image_url') String? get imageUrl; String get location;@JsonKey(name: 'time_in_start') String get timeInStart;@JsonKey(name: 'time_in_end') String get timeInEnd;@JsonKey(name: 'time_out_start') String get timeOutStart;@JsonKey(name: 'time_out_end') String get timeOutEnd;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String get scopeId;@JsonKey(name: 'is_mandatory') bool get isMandatory;@JsonKey(name: 'academic_term_id') String? get academicTermId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'created_by_user_id') String? get createdByUserId;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.fullDescription, fullDescription) || other.fullDescription == fullDescription)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeInStart, timeInStart) || other.timeInStart == timeInStart)&&(identical(other.timeInEnd, timeInEnd) || other.timeInEnd == timeInEnd)&&(identical(other.timeOutStart, timeOutStart) || other.timeOutStart == timeOutStart)&&(identical(other.timeOutEnd, timeOutEnd) || other.timeOutEnd == timeOutEnd)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,eventDate,shortDescription,fullDescription,imageUrl,location,timeInStart,timeInEnd,timeOutStart,timeOutEnd,scopeType,scopeId,isMandatory,academicTermId,createdAt,updatedAt,createdByUserId);

@override
String toString() {
  return 'EventModel(id: $id, name: $name, eventDate: $eventDate, shortDescription: $shortDescription, fullDescription: $fullDescription, imageUrl: $imageUrl, location: $location, timeInStart: $timeInStart, timeInEnd: $timeInEnd, timeOutStart: $timeOutStart, timeOutEnd: $timeOutEnd, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String? id, String name,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'short_description') String? shortDescription,@JsonKey(name: 'full_description') String? fullDescription,@JsonKey(name: 'image_url') String? imageUrl, String location,@JsonKey(name: 'time_in_start') String timeInStart,@JsonKey(name: 'time_in_end') String timeInEnd,@JsonKey(name: 'time_out_start') String timeOutStart,@JsonKey(name: 'time_out_end') String timeOutEnd,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'is_mandatory') bool isMandatory,@JsonKey(name: 'academic_term_id') String? academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId
});




}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? eventDate = null,Object? shortDescription = freezed,Object? fullDescription = freezed,Object? imageUrl = freezed,Object? location = null,Object? timeInStart = null,Object? timeInEnd = null,Object? timeOutStart = null,Object? timeOutEnd = null,Object? scopeType = null,Object? scopeId = null,Object? isMandatory = null,Object? academicTermId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,fullDescription: freezed == fullDescription ? _self.fullDescription : fullDescription // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeInStart: null == timeInStart ? _self.timeInStart : timeInStart // ignore: cast_nullable_to_non_nullable
as String,timeInEnd: null == timeInEnd ? _self.timeInEnd : timeInEnd // ignore: cast_nullable_to_non_nullable
as String,timeOutStart: null == timeOutStart ? _self.timeOutStart : timeOutStart // ignore: cast_nullable_to_non_nullable
as String,timeOutEnd: null == timeOutEnd ? _self.timeOutEnd : timeOutEnd // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as bool,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'short_description')  String? shortDescription, @JsonKey(name: 'full_description')  String? fullDescription, @JsonKey(name: 'image_url')  String? imageUrl,  String location, @JsonKey(name: 'time_in_start')  String timeInStart, @JsonKey(name: 'time_in_end')  String timeInEnd, @JsonKey(name: 'time_out_start')  String timeOutStart, @JsonKey(name: 'time_out_end')  String timeOutEnd, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.eventDate,_that.shortDescription,_that.fullDescription,_that.imageUrl,_that.location,_that.timeInStart,_that.timeInEnd,_that.timeOutStart,_that.timeOutEnd,_that.scopeType,_that.scopeId,_that.isMandatory,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'short_description')  String? shortDescription, @JsonKey(name: 'full_description')  String? fullDescription, @JsonKey(name: 'image_url')  String? imageUrl,  String location, @JsonKey(name: 'time_in_start')  String timeInStart, @JsonKey(name: 'time_in_end')  String timeInEnd, @JsonKey(name: 'time_out_start')  String timeOutStart, @JsonKey(name: 'time_out_end')  String timeOutEnd, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.name,_that.eventDate,_that.shortDescription,_that.fullDescription,_that.imageUrl,_that.location,_that.timeInStart,_that.timeInEnd,_that.timeOutStart,_that.timeOutEnd,_that.scopeType,_that.scopeId,_that.isMandatory,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'short_description')  String? shortDescription, @JsonKey(name: 'full_description')  String? fullDescription, @JsonKey(name: 'image_url')  String? imageUrl,  String location, @JsonKey(name: 'time_in_start')  String timeInStart, @JsonKey(name: 'time_in_end')  String timeInEnd, @JsonKey(name: 'time_out_start')  String timeOutStart, @JsonKey(name: 'time_out_end')  String timeOutEnd, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'is_mandatory')  bool isMandatory, @JsonKey(name: 'academic_term_id')  String? academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.eventDate,_that.shortDescription,_that.fullDescription,_that.imageUrl,_that.location,_that.timeInStart,_that.timeInEnd,_that.timeOutStart,_that.timeOutEnd,_that.scopeType,_that.scopeId,_that.isMandatory,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel extends EventModel {
  const _EventModel({this.id, required this.name, @JsonKey(name: 'event_date') required this.eventDate, @JsonKey(name: 'short_description') this.shortDescription, @JsonKey(name: 'full_description') this.fullDescription, @JsonKey(name: 'image_url') this.imageUrl, required this.location, @JsonKey(name: 'time_in_start') required this.timeInStart, @JsonKey(name: 'time_in_end') required this.timeInEnd, @JsonKey(name: 'time_out_start') required this.timeOutStart, @JsonKey(name: 'time_out_end') required this.timeOutEnd, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') required this.scopeId, @JsonKey(name: 'is_mandatory') this.isMandatory = true, @JsonKey(name: 'academic_term_id') this.academicTermId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'created_by_user_id') this.createdByUserId}): super._();
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  String? id;
@override final  String name;
@override@JsonKey(name: 'event_date') final  DateTime eventDate;
@override@JsonKey(name: 'short_description') final  String? shortDescription;
@override@JsonKey(name: 'full_description') final  String? fullDescription;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  String location;
@override@JsonKey(name: 'time_in_start') final  String timeInStart;
@override@JsonKey(name: 'time_in_end') final  String timeInEnd;
@override@JsonKey(name: 'time_out_start') final  String timeOutStart;
@override@JsonKey(name: 'time_out_end') final  String timeOutEnd;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String scopeId;
@override@JsonKey(name: 'is_mandatory') final  bool isMandatory;
@override@JsonKey(name: 'academic_term_id') final  String? academicTermId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'created_by_user_id') final  String? createdByUserId;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.fullDescription, fullDescription) || other.fullDescription == fullDescription)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeInStart, timeInStart) || other.timeInStart == timeInStart)&&(identical(other.timeInEnd, timeInEnd) || other.timeInEnd == timeInEnd)&&(identical(other.timeOutStart, timeOutStart) || other.timeOutStart == timeOutStart)&&(identical(other.timeOutEnd, timeOutEnd) || other.timeOutEnd == timeOutEnd)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,eventDate,shortDescription,fullDescription,imageUrl,location,timeInStart,timeInEnd,timeOutStart,timeOutEnd,scopeType,scopeId,isMandatory,academicTermId,createdAt,updatedAt,createdByUserId);

@override
String toString() {
  return 'EventModel(id: $id, name: $name, eventDate: $eventDate, shortDescription: $shortDescription, fullDescription: $fullDescription, imageUrl: $imageUrl, location: $location, timeInStart: $timeInStart, timeInEnd: $timeInEnd, timeOutStart: $timeOutStart, timeOutEnd: $timeOutEnd, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'short_description') String? shortDescription,@JsonKey(name: 'full_description') String? fullDescription,@JsonKey(name: 'image_url') String? imageUrl, String location,@JsonKey(name: 'time_in_start') String timeInStart,@JsonKey(name: 'time_in_end') String timeInEnd,@JsonKey(name: 'time_out_start') String timeOutStart,@JsonKey(name: 'time_out_end') String timeOutEnd,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'is_mandatory') bool isMandatory,@JsonKey(name: 'academic_term_id') String? academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId
});




}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? eventDate = null,Object? shortDescription = freezed,Object? fullDescription = freezed,Object? imageUrl = freezed,Object? location = null,Object? timeInStart = null,Object? timeInEnd = null,Object? timeOutStart = null,Object? timeOutEnd = null,Object? scopeType = null,Object? scopeId = null,Object? isMandatory = null,Object? academicTermId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,}) {
  return _then(_EventModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,fullDescription: freezed == fullDescription ? _self.fullDescription : fullDescription // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeInStart: null == timeInStart ? _self.timeInStart : timeInStart // ignore: cast_nullable_to_non_nullable
as String,timeInEnd: null == timeInEnd ? _self.timeInEnd : timeInEnd // ignore: cast_nullable_to_non_nullable
as String,timeOutStart: null == timeOutStart ? _self.timeOutStart : timeOutStart // ignore: cast_nullable_to_non_nullable
as String,timeOutEnd: null == timeOutEnd ? _self.timeOutEnd : timeOutEnd // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as bool,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
