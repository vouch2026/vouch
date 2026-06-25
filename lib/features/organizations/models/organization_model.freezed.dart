// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationModel {

 String get id; String get name; String get code; String? get description;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'banner_url') String? get bannerUrl; String get status; String get type; String? get facultyProgram; String? get adviserName;@JsonKey(name: 'campus_id') String? get campusId;@JsonKey(name: 'faculty_id') String? get facultyId;@JsonKey(name: 'program_id') String? get programId; int get memberCount;@JsonKey(name: 'requires_adviser_signature') bool get requiresAdviserSignature;@JsonKey(name: 'requires_faculty_dean_signature') bool get requiresFacultyDeanSignature;@JsonKey(name: 'allow_member_card_printing') bool get allowMemberCardPrinting;@JsonKey(name: 'is_clearance_active') bool get isClearanceActive;@JsonKey(name: 'clearance_period_start') DateTime? get clearancePeriodStart;@JsonKey(name: 'clearance_period_end') DateTime? get clearancePeriodEnd;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationModelCopyWith<OrganizationModel> get copyWith => _$OrganizationModelCopyWithImpl<OrganizationModel>(this as OrganizationModel, _$identity);

  /// Serializes this OrganizationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.facultyProgram, facultyProgram) || other.facultyProgram == facultyProgram)&&(identical(other.adviserName, adviserName) || other.adviserName == adviserName)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.requiresAdviserSignature, requiresAdviserSignature) || other.requiresAdviserSignature == requiresAdviserSignature)&&(identical(other.requiresFacultyDeanSignature, requiresFacultyDeanSignature) || other.requiresFacultyDeanSignature == requiresFacultyDeanSignature)&&(identical(other.allowMemberCardPrinting, allowMemberCardPrinting) || other.allowMemberCardPrinting == allowMemberCardPrinting)&&(identical(other.isClearanceActive, isClearanceActive) || other.isClearanceActive == isClearanceActive)&&(identical(other.clearancePeriodStart, clearancePeriodStart) || other.clearancePeriodStart == clearancePeriodStart)&&(identical(other.clearancePeriodEnd, clearancePeriodEnd) || other.clearancePeriodEnd == clearancePeriodEnd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,code,description,logoUrl,bannerUrl,status,type,facultyProgram,adviserName,campusId,facultyId,programId,memberCount,requiresAdviserSignature,requiresFacultyDeanSignature,allowMemberCardPrinting,isClearanceActive,clearancePeriodStart,clearancePeriodEnd,createdAt]);

@override
String toString() {
  return 'OrganizationModel(id: $id, name: $name, code: $code, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, status: $status, type: $type, facultyProgram: $facultyProgram, adviserName: $adviserName, campusId: $campusId, facultyId: $facultyId, programId: $programId, memberCount: $memberCount, requiresAdviserSignature: $requiresAdviserSignature, requiresFacultyDeanSignature: $requiresFacultyDeanSignature, allowMemberCardPrinting: $allowMemberCardPrinting, isClearanceActive: $isClearanceActive, clearancePeriodStart: $clearancePeriodStart, clearancePeriodEnd: $clearancePeriodEnd, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrganizationModelCopyWith<$Res>  {
  factory $OrganizationModelCopyWith(OrganizationModel value, $Res Function(OrganizationModel) _then) = _$OrganizationModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code, String? description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl, String status, String type, String? facultyProgram, String? adviserName,@JsonKey(name: 'campus_id') String? campusId,@JsonKey(name: 'faculty_id') String? facultyId,@JsonKey(name: 'program_id') String? programId, int memberCount,@JsonKey(name: 'requires_adviser_signature') bool requiresAdviserSignature,@JsonKey(name: 'requires_faculty_dean_signature') bool requiresFacultyDeanSignature,@JsonKey(name: 'allow_member_card_printing') bool allowMemberCardPrinting,@JsonKey(name: 'is_clearance_active') bool isClearanceActive,@JsonKey(name: 'clearance_period_start') DateTime? clearancePeriodStart,@JsonKey(name: 'clearance_period_end') DateTime? clearancePeriodEnd,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$OrganizationModelCopyWithImpl<$Res>
    implements $OrganizationModelCopyWith<$Res> {
  _$OrganizationModelCopyWithImpl(this._self, this._then);

  final OrganizationModel _self;
  final $Res Function(OrganizationModel) _then;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? description = freezed,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? status = null,Object? type = null,Object? facultyProgram = freezed,Object? adviserName = freezed,Object? campusId = freezed,Object? facultyId = freezed,Object? programId = freezed,Object? memberCount = null,Object? requiresAdviserSignature = null,Object? requiresFacultyDeanSignature = null,Object? allowMemberCardPrinting = null,Object? isClearanceActive = null,Object? clearancePeriodStart = freezed,Object? clearancePeriodEnd = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,facultyProgram: freezed == facultyProgram ? _self.facultyProgram : facultyProgram // ignore: cast_nullable_to_non_nullable
as String?,adviserName: freezed == adviserName ? _self.adviserName : adviserName // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,requiresAdviserSignature: null == requiresAdviserSignature ? _self.requiresAdviserSignature : requiresAdviserSignature // ignore: cast_nullable_to_non_nullable
as bool,requiresFacultyDeanSignature: null == requiresFacultyDeanSignature ? _self.requiresFacultyDeanSignature : requiresFacultyDeanSignature // ignore: cast_nullable_to_non_nullable
as bool,allowMemberCardPrinting: null == allowMemberCardPrinting ? _self.allowMemberCardPrinting : allowMemberCardPrinting // ignore: cast_nullable_to_non_nullable
as bool,isClearanceActive: null == isClearanceActive ? _self.isClearanceActive : isClearanceActive // ignore: cast_nullable_to_non_nullable
as bool,clearancePeriodStart: freezed == clearancePeriodStart ? _self.clearancePeriodStart : clearancePeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,clearancePeriodEnd: freezed == clearancePeriodEnd ? _self.clearancePeriodEnd : clearancePeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationModel].
extension OrganizationModelPatterns on OrganizationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationModel value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String? description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  String status,  String type,  String? facultyProgram,  String? adviserName, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId,  int memberCount, @JsonKey(name: 'requires_adviser_signature')  bool requiresAdviserSignature, @JsonKey(name: 'requires_faculty_dean_signature')  bool requiresFacultyDeanSignature, @JsonKey(name: 'allow_member_card_printing')  bool allowMemberCardPrinting, @JsonKey(name: 'is_clearance_active')  bool isClearanceActive, @JsonKey(name: 'clearance_period_start')  DateTime? clearancePeriodStart, @JsonKey(name: 'clearance_period_end')  DateTime? clearancePeriodEnd, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.description,_that.logoUrl,_that.bannerUrl,_that.status,_that.type,_that.facultyProgram,_that.adviserName,_that.campusId,_that.facultyId,_that.programId,_that.memberCount,_that.requiresAdviserSignature,_that.requiresFacultyDeanSignature,_that.allowMemberCardPrinting,_that.isClearanceActive,_that.clearancePeriodStart,_that.clearancePeriodEnd,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String? description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  String status,  String type,  String? facultyProgram,  String? adviserName, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId,  int memberCount, @JsonKey(name: 'requires_adviser_signature')  bool requiresAdviserSignature, @JsonKey(name: 'requires_faculty_dean_signature')  bool requiresFacultyDeanSignature, @JsonKey(name: 'allow_member_card_printing')  bool allowMemberCardPrinting, @JsonKey(name: 'is_clearance_active')  bool isClearanceActive, @JsonKey(name: 'clearance_period_start')  DateTime? clearancePeriodStart, @JsonKey(name: 'clearance_period_end')  DateTime? clearancePeriodEnd, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrganizationModel():
return $default(_that.id,_that.name,_that.code,_that.description,_that.logoUrl,_that.bannerUrl,_that.status,_that.type,_that.facultyProgram,_that.adviserName,_that.campusId,_that.facultyId,_that.programId,_that.memberCount,_that.requiresAdviserSignature,_that.requiresFacultyDeanSignature,_that.allowMemberCardPrinting,_that.isClearanceActive,_that.clearancePeriodStart,_that.clearancePeriodEnd,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code,  String? description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  String status,  String type,  String? facultyProgram,  String? adviserName, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId,  int memberCount, @JsonKey(name: 'requires_adviser_signature')  bool requiresAdviserSignature, @JsonKey(name: 'requires_faculty_dean_signature')  bool requiresFacultyDeanSignature, @JsonKey(name: 'allow_member_card_printing')  bool allowMemberCardPrinting, @JsonKey(name: 'is_clearance_active')  bool isClearanceActive, @JsonKey(name: 'clearance_period_start')  DateTime? clearancePeriodStart, @JsonKey(name: 'clearance_period_end')  DateTime? clearancePeriodEnd, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.description,_that.logoUrl,_that.bannerUrl,_that.status,_that.type,_that.facultyProgram,_that.adviserName,_that.campusId,_that.facultyId,_that.programId,_that.memberCount,_that.requiresAdviserSignature,_that.requiresFacultyDeanSignature,_that.allowMemberCardPrinting,_that.isClearanceActive,_that.clearancePeriodStart,_that.clearancePeriodEnd,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationModel implements OrganizationModel {
  const _OrganizationModel({required this.id, required this.name, required this.code, this.description, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'banner_url') this.bannerUrl, this.status = 'active', this.type = 'campus-based', this.facultyProgram, this.adviserName, @JsonKey(name: 'campus_id') this.campusId, @JsonKey(name: 'faculty_id') this.facultyId, @JsonKey(name: 'program_id') this.programId, this.memberCount = 0, @JsonKey(name: 'requires_adviser_signature') this.requiresAdviserSignature = false, @JsonKey(name: 'requires_faculty_dean_signature') this.requiresFacultyDeanSignature = false, @JsonKey(name: 'allow_member_card_printing') this.allowMemberCardPrinting = true, @JsonKey(name: 'is_clearance_active') this.isClearanceActive = false, @JsonKey(name: 'clearance_period_start') this.clearancePeriodStart, @JsonKey(name: 'clearance_period_end') this.clearancePeriodEnd, @JsonKey(name: 'created_at') this.createdAt});
  factory _OrganizationModel.fromJson(Map<String, dynamic> json) => _$OrganizationModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String code;
@override final  String? description;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
@override@JsonKey() final  String status;
@override@JsonKey() final  String type;
@override final  String? facultyProgram;
@override final  String? adviserName;
@override@JsonKey(name: 'campus_id') final  String? campusId;
@override@JsonKey(name: 'faculty_id') final  String? facultyId;
@override@JsonKey(name: 'program_id') final  String? programId;
@override@JsonKey() final  int memberCount;
@override@JsonKey(name: 'requires_adviser_signature') final  bool requiresAdviserSignature;
@override@JsonKey(name: 'requires_faculty_dean_signature') final  bool requiresFacultyDeanSignature;
@override@JsonKey(name: 'allow_member_card_printing') final  bool allowMemberCardPrinting;
@override@JsonKey(name: 'is_clearance_active') final  bool isClearanceActive;
@override@JsonKey(name: 'clearance_period_start') final  DateTime? clearancePeriodStart;
@override@JsonKey(name: 'clearance_period_end') final  DateTime? clearancePeriodEnd;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationModelCopyWith<_OrganizationModel> get copyWith => __$OrganizationModelCopyWithImpl<_OrganizationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.facultyProgram, facultyProgram) || other.facultyProgram == facultyProgram)&&(identical(other.adviserName, adviserName) || other.adviserName == adviserName)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.requiresAdviserSignature, requiresAdviserSignature) || other.requiresAdviserSignature == requiresAdviserSignature)&&(identical(other.requiresFacultyDeanSignature, requiresFacultyDeanSignature) || other.requiresFacultyDeanSignature == requiresFacultyDeanSignature)&&(identical(other.allowMemberCardPrinting, allowMemberCardPrinting) || other.allowMemberCardPrinting == allowMemberCardPrinting)&&(identical(other.isClearanceActive, isClearanceActive) || other.isClearanceActive == isClearanceActive)&&(identical(other.clearancePeriodStart, clearancePeriodStart) || other.clearancePeriodStart == clearancePeriodStart)&&(identical(other.clearancePeriodEnd, clearancePeriodEnd) || other.clearancePeriodEnd == clearancePeriodEnd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,code,description,logoUrl,bannerUrl,status,type,facultyProgram,adviserName,campusId,facultyId,programId,memberCount,requiresAdviserSignature,requiresFacultyDeanSignature,allowMemberCardPrinting,isClearanceActive,clearancePeriodStart,clearancePeriodEnd,createdAt]);

@override
String toString() {
  return 'OrganizationModel(id: $id, name: $name, code: $code, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, status: $status, type: $type, facultyProgram: $facultyProgram, adviserName: $adviserName, campusId: $campusId, facultyId: $facultyId, programId: $programId, memberCount: $memberCount, requiresAdviserSignature: $requiresAdviserSignature, requiresFacultyDeanSignature: $requiresFacultyDeanSignature, allowMemberCardPrinting: $allowMemberCardPrinting, isClearanceActive: $isClearanceActive, clearancePeriodStart: $clearancePeriodStart, clearancePeriodEnd: $clearancePeriodEnd, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrganizationModelCopyWith<$Res> implements $OrganizationModelCopyWith<$Res> {
  factory _$OrganizationModelCopyWith(_OrganizationModel value, $Res Function(_OrganizationModel) _then) = __$OrganizationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code, String? description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl, String status, String type, String? facultyProgram, String? adviserName,@JsonKey(name: 'campus_id') String? campusId,@JsonKey(name: 'faculty_id') String? facultyId,@JsonKey(name: 'program_id') String? programId, int memberCount,@JsonKey(name: 'requires_adviser_signature') bool requiresAdviserSignature,@JsonKey(name: 'requires_faculty_dean_signature') bool requiresFacultyDeanSignature,@JsonKey(name: 'allow_member_card_printing') bool allowMemberCardPrinting,@JsonKey(name: 'is_clearance_active') bool isClearanceActive,@JsonKey(name: 'clearance_period_start') DateTime? clearancePeriodStart,@JsonKey(name: 'clearance_period_end') DateTime? clearancePeriodEnd,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$OrganizationModelCopyWithImpl<$Res>
    implements _$OrganizationModelCopyWith<$Res> {
  __$OrganizationModelCopyWithImpl(this._self, this._then);

  final _OrganizationModel _self;
  final $Res Function(_OrganizationModel) _then;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? description = freezed,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? status = null,Object? type = null,Object? facultyProgram = freezed,Object? adviserName = freezed,Object? campusId = freezed,Object? facultyId = freezed,Object? programId = freezed,Object? memberCount = null,Object? requiresAdviserSignature = null,Object? requiresFacultyDeanSignature = null,Object? allowMemberCardPrinting = null,Object? isClearanceActive = null,Object? clearancePeriodStart = freezed,Object? clearancePeriodEnd = freezed,Object? createdAt = freezed,}) {
  return _then(_OrganizationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,facultyProgram: freezed == facultyProgram ? _self.facultyProgram : facultyProgram // ignore: cast_nullable_to_non_nullable
as String?,adviserName: freezed == adviserName ? _self.adviserName : adviserName // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,requiresAdviserSignature: null == requiresAdviserSignature ? _self.requiresAdviserSignature : requiresAdviserSignature // ignore: cast_nullable_to_non_nullable
as bool,requiresFacultyDeanSignature: null == requiresFacultyDeanSignature ? _self.requiresFacultyDeanSignature : requiresFacultyDeanSignature // ignore: cast_nullable_to_non_nullable
as bool,allowMemberCardPrinting: null == allowMemberCardPrinting ? _self.allowMemberCardPrinting : allowMemberCardPrinting // ignore: cast_nullable_to_non_nullable
as bool,isClearanceActive: null == isClearanceActive ? _self.isClearanceActive : isClearanceActive // ignore: cast_nullable_to_non_nullable
as bool,clearancePeriodStart: freezed == clearancePeriodStart ? _self.clearancePeriodStart : clearancePeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,clearancePeriodEnd: freezed == clearancePeriodEnd ? _self.clearancePeriodEnd : clearancePeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
