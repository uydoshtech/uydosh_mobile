// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messaging_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagingState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState()';
}


}

/// @nodoc
class $MessagingStateCopyWith<$Res>  {
$MessagingStateCopyWith(MessagingState _, $Res Function(MessagingState) __);
}


/// Adds pattern-matching-related methods to [MessagingState].
extension MessagingStatePatterns on MessagingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessagingInitial value)?  initial,TResult Function( MessagingLoading value)?  loading,TResult Function( MessagingConversationsLoaded value)?  conversationsLoaded,TResult Function( MessagingConversationsCleared value)?  conversationsCleared,TResult Function( MessagesLoaded value)?  messagesLoaded,TResult Function( ConversationCreated value)?  conversationCreated,TResult Function( MessageSent value)?  messageSent,TResult Function( MessageEdited value)?  messageEdited,TResult Function( MessagesMarkedAsRead value)?  messagesMarkedAsRead,TResult Function( MessagingError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessagingInitial() when initial != null:
return initial(_that);case MessagingLoading() when loading != null:
return loading(_that);case MessagingConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that);case MessagingConversationsCleared() when conversationsCleared != null:
return conversationsCleared(_that);case MessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that);case ConversationCreated() when conversationCreated != null:
return conversationCreated(_that);case MessageSent() when messageSent != null:
return messageSent(_that);case MessageEdited() when messageEdited != null:
return messageEdited(_that);case MessagesMarkedAsRead() when messagesMarkedAsRead != null:
return messagesMarkedAsRead(_that);case MessagingError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessagingInitial value)  initial,required TResult Function( MessagingLoading value)  loading,required TResult Function( MessagingConversationsLoaded value)  conversationsLoaded,required TResult Function( MessagingConversationsCleared value)  conversationsCleared,required TResult Function( MessagesLoaded value)  messagesLoaded,required TResult Function( ConversationCreated value)  conversationCreated,required TResult Function( MessageSent value)  messageSent,required TResult Function( MessageEdited value)  messageEdited,required TResult Function( MessagesMarkedAsRead value)  messagesMarkedAsRead,required TResult Function( MessagingError value)  error,}){
final _that = this;
switch (_that) {
case MessagingInitial():
return initial(_that);case MessagingLoading():
return loading(_that);case MessagingConversationsLoaded():
return conversationsLoaded(_that);case MessagingConversationsCleared():
return conversationsCleared(_that);case MessagesLoaded():
return messagesLoaded(_that);case ConversationCreated():
return conversationCreated(_that);case MessageSent():
return messageSent(_that);case MessageEdited():
return messageEdited(_that);case MessagesMarkedAsRead():
return messagesMarkedAsRead(_that);case MessagingError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessagingInitial value)?  initial,TResult? Function( MessagingLoading value)?  loading,TResult? Function( MessagingConversationsLoaded value)?  conversationsLoaded,TResult? Function( MessagingConversationsCleared value)?  conversationsCleared,TResult? Function( MessagesLoaded value)?  messagesLoaded,TResult? Function( ConversationCreated value)?  conversationCreated,TResult? Function( MessageSent value)?  messageSent,TResult? Function( MessageEdited value)?  messageEdited,TResult? Function( MessagesMarkedAsRead value)?  messagesMarkedAsRead,TResult? Function( MessagingError value)?  error,}){
final _that = this;
switch (_that) {
case MessagingInitial() when initial != null:
return initial(_that);case MessagingLoading() when loading != null:
return loading(_that);case MessagingConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that);case MessagingConversationsCleared() when conversationsCleared != null:
return conversationsCleared(_that);case MessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that);case ConversationCreated() when conversationCreated != null:
return conversationCreated(_that);case MessageSent() when messageSent != null:
return messageSent(_that);case MessageEdited() when messageEdited != null:
return messageEdited(_that);case MessagesMarkedAsRead() when messagesMarkedAsRead != null:
return messagesMarkedAsRead(_that);case MessagingError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ConversationSummary> conversations,  bool hasMore,  int currentPage)?  conversationsLoaded,TResult Function()?  conversationsCleared,TResult Function( List<Message> messages,  bool hasMore,  int currentPage,  int conversationId)?  messagesLoaded,TResult Function( Conversation conversation)?  conversationCreated,TResult Function( Message message)?  messageSent,TResult Function( Message message)?  messageEdited,TResult Function( int conversationId,  int markedCount)?  messagesMarkedAsRead,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessagingInitial() when initial != null:
return initial();case MessagingLoading() when loading != null:
return loading();case MessagingConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that.conversations,_that.hasMore,_that.currentPage);case MessagingConversationsCleared() when conversationsCleared != null:
return conversationsCleared();case MessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that.messages,_that.hasMore,_that.currentPage,_that.conversationId);case ConversationCreated() when conversationCreated != null:
return conversationCreated(_that.conversation);case MessageSent() when messageSent != null:
return messageSent(_that.message);case MessageEdited() when messageEdited != null:
return messageEdited(_that.message);case MessagesMarkedAsRead() when messagesMarkedAsRead != null:
return messagesMarkedAsRead(_that.conversationId,_that.markedCount);case MessagingError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ConversationSummary> conversations,  bool hasMore,  int currentPage)  conversationsLoaded,required TResult Function()  conversationsCleared,required TResult Function( List<Message> messages,  bool hasMore,  int currentPage,  int conversationId)  messagesLoaded,required TResult Function( Conversation conversation)  conversationCreated,required TResult Function( Message message)  messageSent,required TResult Function( Message message)  messageEdited,required TResult Function( int conversationId,  int markedCount)  messagesMarkedAsRead,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case MessagingInitial():
return initial();case MessagingLoading():
return loading();case MessagingConversationsLoaded():
return conversationsLoaded(_that.conversations,_that.hasMore,_that.currentPage);case MessagingConversationsCleared():
return conversationsCleared();case MessagesLoaded():
return messagesLoaded(_that.messages,_that.hasMore,_that.currentPage,_that.conversationId);case ConversationCreated():
return conversationCreated(_that.conversation);case MessageSent():
return messageSent(_that.message);case MessageEdited():
return messageEdited(_that.message);case MessagesMarkedAsRead():
return messagesMarkedAsRead(_that.conversationId,_that.markedCount);case MessagingError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ConversationSummary> conversations,  bool hasMore,  int currentPage)?  conversationsLoaded,TResult? Function()?  conversationsCleared,TResult? Function( List<Message> messages,  bool hasMore,  int currentPage,  int conversationId)?  messagesLoaded,TResult? Function( Conversation conversation)?  conversationCreated,TResult? Function( Message message)?  messageSent,TResult? Function( Message message)?  messageEdited,TResult? Function( int conversationId,  int markedCount)?  messagesMarkedAsRead,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case MessagingInitial() when initial != null:
return initial();case MessagingLoading() when loading != null:
return loading();case MessagingConversationsLoaded() when conversationsLoaded != null:
return conversationsLoaded(_that.conversations,_that.hasMore,_that.currentPage);case MessagingConversationsCleared() when conversationsCleared != null:
return conversationsCleared();case MessagesLoaded() when messagesLoaded != null:
return messagesLoaded(_that.messages,_that.hasMore,_that.currentPage,_that.conversationId);case ConversationCreated() when conversationCreated != null:
return conversationCreated(_that.conversation);case MessageSent() when messageSent != null:
return messageSent(_that.message);case MessageEdited() when messageEdited != null:
return messageEdited(_that.message);case MessagesMarkedAsRead() when messagesMarkedAsRead != null:
return messagesMarkedAsRead(_that.conversationId,_that.markedCount);case MessagingError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MessagingInitial with DiagnosticableTreeMixin implements MessagingState {
  const MessagingInitial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.initial()';
}


}




/// @nodoc


class MessagingLoading with DiagnosticableTreeMixin implements MessagingState {
  const MessagingLoading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.loading'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.loading()';
}


}




/// @nodoc


class MessagingConversationsLoaded with DiagnosticableTreeMixin implements MessagingState {
  const MessagingConversationsLoaded({required final  List<ConversationSummary> conversations, required this.hasMore, required this.currentPage}): _conversations = conversations;
  

 final  List<ConversationSummary> _conversations;
 List<ConversationSummary> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

 final  bool hasMore;
 final  int currentPage;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagingConversationsLoadedCopyWith<MessagingConversationsLoaded> get copyWith => _$MessagingConversationsLoadedCopyWithImpl<MessagingConversationsLoaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.conversationsLoaded'))
    ..add(DiagnosticsProperty('conversations', conversations))..add(DiagnosticsProperty('hasMore', hasMore))..add(DiagnosticsProperty('currentPage', currentPage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingConversationsLoaded&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conversations),hasMore,currentPage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.conversationsLoaded(conversations: $conversations, hasMore: $hasMore, currentPage: $currentPage)';
}


}

/// @nodoc
abstract mixin class $MessagingConversationsLoadedCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessagingConversationsLoadedCopyWith(MessagingConversationsLoaded value, $Res Function(MessagingConversationsLoaded) _then) = _$MessagingConversationsLoadedCopyWithImpl;
@useResult
$Res call({
 List<ConversationSummary> conversations, bool hasMore, int currentPage
});




}
/// @nodoc
class _$MessagingConversationsLoadedCopyWithImpl<$Res>
    implements $MessagingConversationsLoadedCopyWith<$Res> {
  _$MessagingConversationsLoadedCopyWithImpl(this._self, this._then);

  final MessagingConversationsLoaded _self;
  final $Res Function(MessagingConversationsLoaded) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversations = null,Object? hasMore = null,Object? currentPage = null,}) {
  return _then(MessagingConversationsLoaded(
conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ConversationSummary>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class MessagingConversationsCleared with DiagnosticableTreeMixin implements MessagingState {
  const MessagingConversationsCleared();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.conversationsCleared'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingConversationsCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.conversationsCleared()';
}


}




/// @nodoc


class MessagesLoaded with DiagnosticableTreeMixin implements MessagingState {
  const MessagesLoaded({required final  List<Message> messages, required this.hasMore, required this.currentPage, required this.conversationId}): _messages = messages;
  

 final  List<Message> _messages;
 List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  bool hasMore;
 final  int currentPage;
 final  int conversationId;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagesLoadedCopyWith<MessagesLoaded> get copyWith => _$MessagesLoadedCopyWithImpl<MessagesLoaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.messagesLoaded'))
    ..add(DiagnosticsProperty('messages', messages))..add(DiagnosticsProperty('hasMore', hasMore))..add(DiagnosticsProperty('currentPage', currentPage))..add(DiagnosticsProperty('conversationId', conversationId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesLoaded&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),hasMore,currentPage,conversationId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.messagesLoaded(messages: $messages, hasMore: $hasMore, currentPage: $currentPage, conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class $MessagesLoadedCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessagesLoadedCopyWith(MessagesLoaded value, $Res Function(MessagesLoaded) _then) = _$MessagesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Message> messages, bool hasMore, int currentPage, int conversationId
});




}
/// @nodoc
class _$MessagesLoadedCopyWithImpl<$Res>
    implements $MessagesLoadedCopyWith<$Res> {
  _$MessagesLoadedCopyWithImpl(this._self, this._then);

  final MessagesLoaded _self;
  final $Res Function(MessagesLoaded) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? hasMore = null,Object? currentPage = null,Object? conversationId = null,}) {
  return _then(MessagesLoaded(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ConversationCreated with DiagnosticableTreeMixin implements MessagingState {
  const ConversationCreated({required this.conversation});
  

 final  Conversation conversation;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCreatedCopyWith<ConversationCreated> get copyWith => _$ConversationCreatedCopyWithImpl<ConversationCreated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.conversationCreated'))
    ..add(DiagnosticsProperty('conversation', conversation));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationCreated&&(identical(other.conversation, conversation) || other.conversation == conversation));
}


@override
int get hashCode => Object.hash(runtimeType,conversation);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.conversationCreated(conversation: $conversation)';
}


}

/// @nodoc
abstract mixin class $ConversationCreatedCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $ConversationCreatedCopyWith(ConversationCreated value, $Res Function(ConversationCreated) _then) = _$ConversationCreatedCopyWithImpl;
@useResult
$Res call({
 Conversation conversation
});


$ConversationCopyWith<$Res> get conversation;

}
/// @nodoc
class _$ConversationCreatedCopyWithImpl<$Res>
    implements $ConversationCreatedCopyWith<$Res> {
  _$ConversationCreatedCopyWithImpl(this._self, this._then);

  final ConversationCreated _self;
  final $Res Function(ConversationCreated) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversation = null,}) {
  return _then(ConversationCreated(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation,
  ));
}

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res> get conversation {
  
  return $ConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}
}

/// @nodoc


class MessageSent with DiagnosticableTreeMixin implements MessagingState {
  const MessageSent({required this.message});
  

 final  Message message;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSentCopyWith<MessageSent> get copyWith => _$MessageSentCopyWithImpl<MessageSent>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.messageSent'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSent&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.messageSent(message: $message)';
}


}

/// @nodoc
abstract mixin class $MessageSentCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessageSentCopyWith(MessageSent value, $Res Function(MessageSent) _then) = _$MessageSentCopyWithImpl;
@useResult
$Res call({
 Message message
});


$MessageCopyWith<$Res> get message;

}
/// @nodoc
class _$MessageSentCopyWithImpl<$Res>
    implements $MessageSentCopyWith<$Res> {
  _$MessageSentCopyWithImpl(this._self, this._then);

  final MessageSent _self;
  final $Res Function(MessageSent) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MessageSent(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Message,
  ));
}

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res> get message {
  
  return $MessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

/// @nodoc


class MessageEdited with DiagnosticableTreeMixin implements MessagingState {
  const MessageEdited({required this.message});
  

 final  Message message;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageEditedCopyWith<MessageEdited> get copyWith => _$MessageEditedCopyWithImpl<MessageEdited>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.messageEdited'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageEdited&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.messageEdited(message: $message)';
}


}

/// @nodoc
abstract mixin class $MessageEditedCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessageEditedCopyWith(MessageEdited value, $Res Function(MessageEdited) _then) = _$MessageEditedCopyWithImpl;
@useResult
$Res call({
 Message message
});


$MessageCopyWith<$Res> get message;

}
/// @nodoc
class _$MessageEditedCopyWithImpl<$Res>
    implements $MessageEditedCopyWith<$Res> {
  _$MessageEditedCopyWithImpl(this._self, this._then);

  final MessageEdited _self;
  final $Res Function(MessageEdited) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MessageEdited(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Message,
  ));
}

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res> get message {
  
  return $MessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

/// @nodoc


class MessagesMarkedAsRead with DiagnosticableTreeMixin implements MessagingState {
  const MessagesMarkedAsRead({required this.conversationId, required this.markedCount});
  

 final  int conversationId;
 final  int markedCount;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagesMarkedAsReadCopyWith<MessagesMarkedAsRead> get copyWith => _$MessagesMarkedAsReadCopyWithImpl<MessagesMarkedAsRead>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.messagesMarkedAsRead'))
    ..add(DiagnosticsProperty('conversationId', conversationId))..add(DiagnosticsProperty('markedCount', markedCount));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesMarkedAsRead&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.markedCount, markedCount) || other.markedCount == markedCount));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,markedCount);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.messagesMarkedAsRead(conversationId: $conversationId, markedCount: $markedCount)';
}


}

/// @nodoc
abstract mixin class $MessagesMarkedAsReadCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessagesMarkedAsReadCopyWith(MessagesMarkedAsRead value, $Res Function(MessagesMarkedAsRead) _then) = _$MessagesMarkedAsReadCopyWithImpl;
@useResult
$Res call({
 int conversationId, int markedCount
});




}
/// @nodoc
class _$MessagesMarkedAsReadCopyWithImpl<$Res>
    implements $MessagesMarkedAsReadCopyWith<$Res> {
  _$MessagesMarkedAsReadCopyWithImpl(this._self, this._then);

  final MessagesMarkedAsRead _self;
  final $Res Function(MessagesMarkedAsRead) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? markedCount = null,}) {
  return _then(MessagesMarkedAsRead(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,markedCount: null == markedCount ? _self.markedCount : markedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class MessagingError with DiagnosticableTreeMixin implements MessagingState {
  const MessagingError({required this.message});
  

 final  String message;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagingErrorCopyWith<MessagingError> get copyWith => _$MessagingErrorCopyWithImpl<MessagingError>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessagingState.error'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessagingState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MessagingErrorCopyWith<$Res> implements $MessagingStateCopyWith<$Res> {
  factory $MessagingErrorCopyWith(MessagingError value, $Res Function(MessagingError) _then) = _$MessagingErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$MessagingErrorCopyWithImpl<$Res>
    implements $MessagingErrorCopyWith<$Res> {
  _$MessagingErrorCopyWithImpl(this._self, this._then);

  final MessagingError _self;
  final $Res Function(MessagingError) _then;

/// Create a copy of MessagingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MessagingError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
