// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnnouncementModel {

 String? get id; String get title; String get content; String get type;@JsonKey(name: 'link_urls') List<String>? get linkUrls;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String get scopeId;@JsonKey(name: 'academic_term_id') String get academicTermId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'created_by_user_id') String? get createdByUserId;// Virtual fields
@JsonKey(includeFromJson: true, includeToJson: false) String? get authorName;
/// Create a copy of AnnouncementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementModelCopyWith<AnnouncementModel> get copyWith => _$AnnouncementModelCopyWithImpl<AnnouncementModel>(this as AnnouncementModel, _$identity);

  /// Serializes this AnnouncementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnouncementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.linkUrls, linkUrls)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,type,const DeepCollectionEquality().hash(linkUrls),imageUrl,scopeType,scopeId,academicTermId,createdAt,updatedAt,createdByUserId,authorName);

@override
String toString() {
  return 'AnnouncementModel(id: $id, title: $title, content: $content, type: $type, linkUrls: $linkUrls, imageUrl: $imageUrl, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class $AnnouncementModelCopyWith<$Res>  {
  factory $AnnouncementModelCopyWith(AnnouncementModel value, $Res Function(AnnouncementModel) _then) = _$AnnouncementModelCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String content, String type,@JsonKey(name: 'link_urls') List<String>? linkUrls,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(includeFromJson: true, includeToJson: false) String? authorName
});




}
/// @nodoc
class _$AnnouncementModelCopyWithImpl<$Res>
    implements $AnnouncementModelCopyWith<$Res> {
  _$AnnouncementModelCopyWithImpl(this._self, this._then);

  final AnnouncementModel _self;
  final $Res Function(AnnouncementModel) _then;

/// Create a copy of AnnouncementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? content = null,Object? type = null,Object? linkUrls = freezed,Object? imageUrl = freezed,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,Object? authorName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,linkUrls: freezed == linkUrls ? _self.linkUrls : linkUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnnouncementModel].
extension AnnouncementModelPatterns on AnnouncementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnouncementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnouncementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnouncementModel value)  $default,){
final _that = this;
switch (_that) {
case _AnnouncementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnouncementModel value)?  $default,){
final _that = this;
switch (_that) {
case _AnnouncementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String content,  String type, @JsonKey(name: 'link_urls')  List<String>? linkUrls, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? authorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnouncementModel() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.type,_that.linkUrls,_that.imageUrl,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.authorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String content,  String type, @JsonKey(name: 'link_urls')  List<String>? linkUrls, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? authorName)  $default,) {final _that = this;
switch (_that) {
case _AnnouncementModel():
return $default(_that.id,_that.title,_that.content,_that.type,_that.linkUrls,_that.imageUrl,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.authorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String content,  String type, @JsonKey(name: 'link_urls')  List<String>? linkUrls, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? authorName)?  $default,) {final _that = this;
switch (_that) {
case _AnnouncementModel() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.type,_that.linkUrls,_that.imageUrl,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.authorName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnnouncementModel implements AnnouncementModel {
  const _AnnouncementModel({this.id, required this.title, required this.content, this.type = 'General', @JsonKey(name: 'link_urls') final  List<String>? linkUrls, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') required this.scopeId, @JsonKey(name: 'academic_term_id') required this.academicTermId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'created_by_user_id') this.createdByUserId, @JsonKey(includeFromJson: true, includeToJson: false) this.authorName}): _linkUrls = linkUrls;
  factory _AnnouncementModel.fromJson(Map<String, dynamic> json) => _$AnnouncementModelFromJson(json);

@override final  String? id;
@override final  String title;
@override final  String content;
@override@JsonKey() final  String type;
 final  List<String>? _linkUrls;
@override@JsonKey(name: 'link_urls') List<String>? get linkUrls {
  final value = _linkUrls;
  if (value == null) return null;
  if (_linkUrls is EqualUnmodifiableListView) return _linkUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String scopeId;
@override@JsonKey(name: 'academic_term_id') final  String academicTermId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'created_by_user_id') final  String? createdByUserId;
// Virtual fields
@override@JsonKey(includeFromJson: true, includeToJson: false) final  String? authorName;

/// Create a copy of AnnouncementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementModelCopyWith<_AnnouncementModel> get copyWith => __$AnnouncementModelCopyWithImpl<_AnnouncementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnouncementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._linkUrls, _linkUrls)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,type,const DeepCollectionEquality().hash(_linkUrls),imageUrl,scopeType,scopeId,academicTermId,createdAt,updatedAt,createdByUserId,authorName);

@override
String toString() {
  return 'AnnouncementModel(id: $id, title: $title, content: $content, type: $type, linkUrls: $linkUrls, imageUrl: $imageUrl, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementModelCopyWith<$Res> implements $AnnouncementModelCopyWith<$Res> {
  factory _$AnnouncementModelCopyWith(_AnnouncementModel value, $Res Function(_AnnouncementModel) _then) = __$AnnouncementModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String content, String type,@JsonKey(name: 'link_urls') List<String>? linkUrls,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(includeFromJson: true, includeToJson: false) String? authorName
});




}
/// @nodoc
class __$AnnouncementModelCopyWithImpl<$Res>
    implements _$AnnouncementModelCopyWith<$Res> {
  __$AnnouncementModelCopyWithImpl(this._self, this._then);

  final _AnnouncementModel _self;
  final $Res Function(_AnnouncementModel) _then;

/// Create a copy of AnnouncementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? content = null,Object? type = null,Object? linkUrls = freezed,Object? imageUrl = freezed,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,Object? authorName = freezed,}) {
  return _then(_AnnouncementModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,linkUrls: freezed == linkUrls ? _self._linkUrls : linkUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
