// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candidate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CandidateModel {

 String get id; String get electionId; String get userId; String get fullName; String get position; String? get partyList; String? get platform; String get status;// pending, approved, rejected, withdrawn, disqualified
 int get votes; String? get avatarUrl; String? get organizationName;
/// Create a copy of CandidateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CandidateModelCopyWith<CandidateModel> get copyWith => _$CandidateModelCopyWithImpl<CandidateModel>(this as CandidateModel, _$identity);

  /// Serializes this CandidateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CandidateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.electionId, electionId) || other.electionId == electionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.position, position) || other.position == position)&&(identical(other.partyList, partyList) || other.partyList == partyList)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,electionId,userId,fullName,position,partyList,platform,status,votes,avatarUrl,organizationName);

@override
String toString() {
  return 'CandidateModel(id: $id, electionId: $electionId, userId: $userId, fullName: $fullName, position: $position, partyList: $partyList, platform: $platform, status: $status, votes: $votes, avatarUrl: $avatarUrl, organizationName: $organizationName)';
}


}

/// @nodoc
abstract mixin class $CandidateModelCopyWith<$Res>  {
  factory $CandidateModelCopyWith(CandidateModel value, $Res Function(CandidateModel) _then) = _$CandidateModelCopyWithImpl;
@useResult
$Res call({
 String id, String electionId, String userId, String fullName, String position, String? partyList, String? platform, String status, int votes, String? avatarUrl, String? organizationName
});




}
/// @nodoc
class _$CandidateModelCopyWithImpl<$Res>
    implements $CandidateModelCopyWith<$Res> {
  _$CandidateModelCopyWithImpl(this._self, this._then);

  final CandidateModel _self;
  final $Res Function(CandidateModel) _then;

/// Create a copy of CandidateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? electionId = null,Object? userId = null,Object? fullName = null,Object? position = null,Object? partyList = freezed,Object? platform = freezed,Object? status = null,Object? votes = null,Object? avatarUrl = freezed,Object? organizationName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,electionId: null == electionId ? _self.electionId : electionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,partyList: freezed == partyList ? _self.partyList : partyList // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,organizationName: freezed == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CandidateModel].
extension CandidateModelPatterns on CandidateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CandidateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CandidateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CandidateModel value)  $default,){
final _that = this;
switch (_that) {
case _CandidateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CandidateModel value)?  $default,){
final _that = this;
switch (_that) {
case _CandidateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String electionId,  String userId,  String fullName,  String position,  String? partyList,  String? platform,  String status,  int votes,  String? avatarUrl,  String? organizationName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CandidateModel() when $default != null:
return $default(_that.id,_that.electionId,_that.userId,_that.fullName,_that.position,_that.partyList,_that.platform,_that.status,_that.votes,_that.avatarUrl,_that.organizationName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String electionId,  String userId,  String fullName,  String position,  String? partyList,  String? platform,  String status,  int votes,  String? avatarUrl,  String? organizationName)  $default,) {final _that = this;
switch (_that) {
case _CandidateModel():
return $default(_that.id,_that.electionId,_that.userId,_that.fullName,_that.position,_that.partyList,_that.platform,_that.status,_that.votes,_that.avatarUrl,_that.organizationName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String electionId,  String userId,  String fullName,  String position,  String? partyList,  String? platform,  String status,  int votes,  String? avatarUrl,  String? organizationName)?  $default,) {final _that = this;
switch (_that) {
case _CandidateModel() when $default != null:
return $default(_that.id,_that.electionId,_that.userId,_that.fullName,_that.position,_that.partyList,_that.platform,_that.status,_that.votes,_that.avatarUrl,_that.organizationName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CandidateModel implements CandidateModel {
  const _CandidateModel({required this.id, required this.electionId, required this.userId, required this.fullName, required this.position, this.partyList, this.platform, this.status = 'pending', this.votes = 0, this.avatarUrl, this.organizationName});
  factory _CandidateModel.fromJson(Map<String, dynamic> json) => _$CandidateModelFromJson(json);

@override final  String id;
@override final  String electionId;
@override final  String userId;
@override final  String fullName;
@override final  String position;
@override final  String? partyList;
@override final  String? platform;
@override@JsonKey() final  String status;
// pending, approved, rejected, withdrawn, disqualified
@override@JsonKey() final  int votes;
@override final  String? avatarUrl;
@override final  String? organizationName;

/// Create a copy of CandidateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CandidateModelCopyWith<_CandidateModel> get copyWith => __$CandidateModelCopyWithImpl<_CandidateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CandidateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CandidateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.electionId, electionId) || other.electionId == electionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.position, position) || other.position == position)&&(identical(other.partyList, partyList) || other.partyList == partyList)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,electionId,userId,fullName,position,partyList,platform,status,votes,avatarUrl,organizationName);

@override
String toString() {
  return 'CandidateModel(id: $id, electionId: $electionId, userId: $userId, fullName: $fullName, position: $position, partyList: $partyList, platform: $platform, status: $status, votes: $votes, avatarUrl: $avatarUrl, organizationName: $organizationName)';
}


}

/// @nodoc
abstract mixin class _$CandidateModelCopyWith<$Res> implements $CandidateModelCopyWith<$Res> {
  factory _$CandidateModelCopyWith(_CandidateModel value, $Res Function(_CandidateModel) _then) = __$CandidateModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String electionId, String userId, String fullName, String position, String? partyList, String? platform, String status, int votes, String? avatarUrl, String? organizationName
});




}
/// @nodoc
class __$CandidateModelCopyWithImpl<$Res>
    implements _$CandidateModelCopyWith<$Res> {
  __$CandidateModelCopyWithImpl(this._self, this._then);

  final _CandidateModel _self;
  final $Res Function(_CandidateModel) _then;

/// Create a copy of CandidateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? electionId = null,Object? userId = null,Object? fullName = null,Object? position = null,Object? partyList = freezed,Object? platform = freezed,Object? status = null,Object? votes = null,Object? avatarUrl = freezed,Object? organizationName = freezed,}) {
  return _then(_CandidateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,electionId: null == electionId ? _self.electionId : electionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,partyList: freezed == partyList ? _self.partyList : partyList // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,organizationName: freezed == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
