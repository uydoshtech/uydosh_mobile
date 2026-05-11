// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messaging_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessagingState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagingStateCopyWith<$Res> {
  factory $MessagingStateCopyWith(
          MessagingState value, $Res Function(MessagingState) then) =
      _$MessagingStateCopyWithImpl<$Res, MessagingState>;
}

/// @nodoc
class _$MessagingStateCopyWithImpl<$Res, $Val extends MessagingState>
    implements $MessagingStateCopyWith<$Res> {
  _$MessagingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MessagingInitialImplCopyWith<$Res> {
  factory _$$MessagingInitialImplCopyWith(_$MessagingInitialImpl value,
          $Res Function(_$MessagingInitialImpl) then) =
      __$$MessagingInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MessagingInitialImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessagingInitialImpl>
    implements _$$MessagingInitialImplCopyWith<$Res> {
  __$$MessagingInitialImplCopyWithImpl(_$MessagingInitialImpl _value,
      $Res Function(_$MessagingInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MessagingInitialImpl
    with DiagnosticableTreeMixin
    implements MessagingInitial {
  const _$MessagingInitialImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.initial()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'MessagingState.initial'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MessagingInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class MessagingInitial implements MessagingState {
  const factory MessagingInitial() = _$MessagingInitialImpl;
}

/// @nodoc
abstract class _$$MessagingLoadingImplCopyWith<$Res> {
  factory _$$MessagingLoadingImplCopyWith(_$MessagingLoadingImpl value,
          $Res Function(_$MessagingLoadingImpl) then) =
      __$$MessagingLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MessagingLoadingImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessagingLoadingImpl>
    implements _$$MessagingLoadingImplCopyWith<$Res> {
  __$$MessagingLoadingImplCopyWithImpl(_$MessagingLoadingImpl _value,
      $Res Function(_$MessagingLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MessagingLoadingImpl
    with DiagnosticableTreeMixin
    implements MessagingLoading {
  const _$MessagingLoadingImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.loading()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'MessagingState.loading'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MessagingLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class MessagingLoading implements MessagingState {
  const factory MessagingLoading() = _$MessagingLoadingImpl;
}

/// @nodoc
abstract class _$$MessagingConversationsLoadedImplCopyWith<$Res> {
  factory _$$MessagingConversationsLoadedImplCopyWith(
          _$MessagingConversationsLoadedImpl value,
          $Res Function(_$MessagingConversationsLoadedImpl) then) =
      __$$MessagingConversationsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ConversationSummary> conversations, bool hasMore, int currentPage});
}

/// @nodoc
class __$$MessagingConversationsLoadedImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res,
        _$MessagingConversationsLoadedImpl>
    implements _$$MessagingConversationsLoadedImplCopyWith<$Res> {
  __$$MessagingConversationsLoadedImplCopyWithImpl(
      _$MessagingConversationsLoadedImpl _value,
      $Res Function(_$MessagingConversationsLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? hasMore = null,
    Object? currentPage = null,
  }) {
    return _then(_$MessagingConversationsLoadedImpl(
      conversations: null == conversations
          ? _value._conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<ConversationSummary>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MessagingConversationsLoadedImpl
    with DiagnosticableTreeMixin
    implements MessagingConversationsLoaded {
  const _$MessagingConversationsLoadedImpl(
      {required final List<ConversationSummary> conversations,
      required this.hasMore,
      required this.currentPage})
      : _conversations = conversations;

  final List<ConversationSummary> _conversations;
  @override
  List<ConversationSummary> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  @override
  final bool hasMore;
  @override
  final int currentPage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.conversationsLoaded(conversations: $conversations, hasMore: $hasMore, currentPage: $currentPage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.conversationsLoaded'))
      ..add(DiagnosticsProperty('conversations', conversations))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('currentPage', currentPage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagingConversationsLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._conversations, _conversations) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      hasMore,
      currentPage);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagingConversationsLoadedImplCopyWith<
          _$MessagingConversationsLoadedImpl>
      get copyWith => __$$MessagingConversationsLoadedImplCopyWithImpl<
          _$MessagingConversationsLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return conversationsLoaded(conversations, hasMore, currentPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return conversationsLoaded?.call(conversations, hasMore, currentPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (conversationsLoaded != null) {
      return conversationsLoaded(conversations, hasMore, currentPage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return conversationsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return conversationsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (conversationsLoaded != null) {
      return conversationsLoaded(this);
    }
    return orElse();
  }
}

abstract class MessagingConversationsLoaded implements MessagingState {
  const factory MessagingConversationsLoaded(
      {required final List<ConversationSummary> conversations,
      required final bool hasMore,
      required final int currentPage}) = _$MessagingConversationsLoadedImpl;

  List<ConversationSummary> get conversations;
  bool get hasMore;
  int get currentPage;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagingConversationsLoadedImplCopyWith<
          _$MessagingConversationsLoadedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessagingConversationsClearedImplCopyWith<$Res> {
  factory _$$MessagingConversationsClearedImplCopyWith(
          _$MessagingConversationsClearedImpl value,
          $Res Function(_$MessagingConversationsClearedImpl) then) =
      __$$MessagingConversationsClearedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MessagingConversationsClearedImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res,
        _$MessagingConversationsClearedImpl>
    implements _$$MessagingConversationsClearedImplCopyWith<$Res> {
  __$$MessagingConversationsClearedImplCopyWithImpl(
      _$MessagingConversationsClearedImpl _value,
      $Res Function(_$MessagingConversationsClearedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MessagingConversationsClearedImpl
    with DiagnosticableTreeMixin
    implements MessagingConversationsCleared {
  const _$MessagingConversationsClearedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.conversationsCleared()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.conversationsCleared'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagingConversationsClearedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return conversationsCleared();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return conversationsCleared?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (conversationsCleared != null) {
      return conversationsCleared();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return conversationsCleared(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return conversationsCleared?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (conversationsCleared != null) {
      return conversationsCleared(this);
    }
    return orElse();
  }
}

abstract class MessagingConversationsCleared implements MessagingState {
  const factory MessagingConversationsCleared() =
      _$MessagingConversationsClearedImpl;
}

/// @nodoc
abstract class _$$MessagesLoadedImplCopyWith<$Res> {
  factory _$$MessagesLoadedImplCopyWith(_$MessagesLoadedImpl value,
          $Res Function(_$MessagesLoadedImpl) then) =
      __$$MessagesLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<Message> messages,
      bool hasMore,
      int currentPage,
      int conversationId});
}

/// @nodoc
class __$$MessagesLoadedImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessagesLoadedImpl>
    implements _$$MessagesLoadedImplCopyWith<$Res> {
  __$$MessagesLoadedImplCopyWithImpl(
      _$MessagesLoadedImpl _value, $Res Function(_$MessagesLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? hasMore = null,
    Object? currentPage = null,
    Object? conversationId = null,
  }) {
    return _then(_$MessagesLoadedImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MessagesLoadedImpl
    with DiagnosticableTreeMixin
    implements MessagesLoaded {
  const _$MessagesLoadedImpl(
      {required final List<Message> messages,
      required this.hasMore,
      required this.currentPage,
      required this.conversationId})
      : _messages = messages;

  final List<Message> _messages;
  @override
  List<Message> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final bool hasMore;
  @override
  final int currentPage;
  @override
  final int conversationId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.messagesLoaded(messages: $messages, hasMore: $hasMore, currentPage: $currentPage, conversationId: $conversationId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.messagesLoaded'))
      ..add(DiagnosticsProperty('messages', messages))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('currentPage', currentPage))
      ..add(DiagnosticsProperty('conversationId', conversationId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesLoadedImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      hasMore,
      currentPage,
      conversationId);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesLoadedImplCopyWith<_$MessagesLoadedImpl> get copyWith =>
      __$$MessagesLoadedImplCopyWithImpl<_$MessagesLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return messagesLoaded(messages, hasMore, currentPage, conversationId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return messagesLoaded?.call(messages, hasMore, currentPage, conversationId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (messagesLoaded != null) {
      return messagesLoaded(messages, hasMore, currentPage, conversationId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return messagesLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return messagesLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (messagesLoaded != null) {
      return messagesLoaded(this);
    }
    return orElse();
  }
}

abstract class MessagesLoaded implements MessagingState {
  const factory MessagesLoaded(
      {required final List<Message> messages,
      required final bool hasMore,
      required final int currentPage,
      required final int conversationId}) = _$MessagesLoadedImpl;

  List<Message> get messages;
  bool get hasMore;
  int get currentPage;
  int get conversationId;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagesLoadedImplCopyWith<_$MessagesLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConversationCreatedImplCopyWith<$Res> {
  factory _$$ConversationCreatedImplCopyWith(_$ConversationCreatedImpl value,
          $Res Function(_$ConversationCreatedImpl) then) =
      __$$ConversationCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Conversation conversation});

  $ConversationCopyWith<$Res> get conversation;
}

/// @nodoc
class __$$ConversationCreatedImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$ConversationCreatedImpl>
    implements _$$ConversationCreatedImplCopyWith<$Res> {
  __$$ConversationCreatedImplCopyWithImpl(_$ConversationCreatedImpl _value,
      $Res Function(_$ConversationCreatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversation = null,
  }) {
    return _then(_$ConversationCreatedImpl(
      conversation: null == conversation
          ? _value.conversation
          : conversation // ignore: cast_nullable_to_non_nullable
              as Conversation,
    ));
  }

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConversationCopyWith<$Res> get conversation {
    return $ConversationCopyWith<$Res>(_value.conversation, (value) {
      return _then(_value.copyWith(conversation: value));
    });
  }
}

/// @nodoc

class _$ConversationCreatedImpl
    with DiagnosticableTreeMixin
    implements ConversationCreated {
  const _$ConversationCreatedImpl({required this.conversation});

  @override
  final Conversation conversation;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.conversationCreated(conversation: $conversation)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.conversationCreated'))
      ..add(DiagnosticsProperty('conversation', conversation));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationCreatedImpl &&
            (identical(other.conversation, conversation) ||
                other.conversation == conversation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversation);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationCreatedImplCopyWith<_$ConversationCreatedImpl> get copyWith =>
      __$$ConversationCreatedImplCopyWithImpl<_$ConversationCreatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return conversationCreated(conversation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return conversationCreated?.call(conversation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (conversationCreated != null) {
      return conversationCreated(conversation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return conversationCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return conversationCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (conversationCreated != null) {
      return conversationCreated(this);
    }
    return orElse();
  }
}

abstract class ConversationCreated implements MessagingState {
  const factory ConversationCreated(
      {required final Conversation conversation}) = _$ConversationCreatedImpl;

  Conversation get conversation;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationCreatedImplCopyWith<_$ConversationCreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessageSentImplCopyWith<$Res> {
  factory _$$MessageSentImplCopyWith(
          _$MessageSentImpl value, $Res Function(_$MessageSentImpl) then) =
      __$$MessageSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Message message});

  $MessageCopyWith<$Res> get message;
}

/// @nodoc
class __$$MessageSentImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessageSentImpl>
    implements _$$MessageSentImplCopyWith<$Res> {
  __$$MessageSentImplCopyWithImpl(
      _$MessageSentImpl _value, $Res Function(_$MessageSentImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$MessageSentImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Message,
    ));
  }

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res> get message {
    return $MessageCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value));
    });
  }
}

/// @nodoc

class _$MessageSentImpl with DiagnosticableTreeMixin implements MessageSent {
  const _$MessageSentImpl({required this.message});

  @override
  final Message message;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.messageSent(message: $message)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.messageSent'))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSentImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      __$$MessageSentImplCopyWithImpl<_$MessageSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return messageSent(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return messageSent?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return messageSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return messageSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(this);
    }
    return orElse();
  }
}

abstract class MessageSent implements MessagingState {
  const factory MessageSent({required final Message message}) =
      _$MessageSentImpl;

  Message get message;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessagesMarkedAsReadImplCopyWith<$Res> {
  factory _$$MessagesMarkedAsReadImplCopyWith(_$MessagesMarkedAsReadImpl value,
          $Res Function(_$MessagesMarkedAsReadImpl) then) =
      __$$MessagesMarkedAsReadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int conversationId, int markedCount});
}

/// @nodoc
class __$$MessagesMarkedAsReadImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessagesMarkedAsReadImpl>
    implements _$$MessagesMarkedAsReadImplCopyWith<$Res> {
  __$$MessagesMarkedAsReadImplCopyWithImpl(_$MessagesMarkedAsReadImpl _value,
      $Res Function(_$MessagesMarkedAsReadImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? markedCount = null,
  }) {
    return _then(_$MessagesMarkedAsReadImpl(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      markedCount: null == markedCount
          ? _value.markedCount
          : markedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MessagesMarkedAsReadImpl
    with DiagnosticableTreeMixin
    implements MessagesMarkedAsRead {
  const _$MessagesMarkedAsReadImpl(
      {required this.conversationId, required this.markedCount});

  @override
  final int conversationId;
  @override
  final int markedCount;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.messagesMarkedAsRead(conversationId: $conversationId, markedCount: $markedCount)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.messagesMarkedAsRead'))
      ..add(DiagnosticsProperty('conversationId', conversationId))
      ..add(DiagnosticsProperty('markedCount', markedCount));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesMarkedAsReadImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.markedCount, markedCount) ||
                other.markedCount == markedCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversationId, markedCount);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesMarkedAsReadImplCopyWith<_$MessagesMarkedAsReadImpl>
      get copyWith =>
          __$$MessagesMarkedAsReadImplCopyWithImpl<_$MessagesMarkedAsReadImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return messagesMarkedAsRead(conversationId, markedCount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return messagesMarkedAsRead?.call(conversationId, markedCount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (messagesMarkedAsRead != null) {
      return messagesMarkedAsRead(conversationId, markedCount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return messagesMarkedAsRead(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return messagesMarkedAsRead?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (messagesMarkedAsRead != null) {
      return messagesMarkedAsRead(this);
    }
    return orElse();
  }
}

abstract class MessagesMarkedAsRead implements MessagingState {
  const factory MessagesMarkedAsRead(
      {required final int conversationId,
      required final int markedCount}) = _$MessagesMarkedAsReadImpl;

  int get conversationId;
  int get markedCount;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagesMarkedAsReadImplCopyWith<_$MessagesMarkedAsReadImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessagingErrorImplCopyWith<$Res> {
  factory _$$MessagingErrorImplCopyWith(_$MessagingErrorImpl value,
          $Res Function(_$MessagingErrorImpl) then) =
      __$$MessagingErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$MessagingErrorImplCopyWithImpl<$Res>
    extends _$MessagingStateCopyWithImpl<$Res, _$MessagingErrorImpl>
    implements _$$MessagingErrorImplCopyWith<$Res> {
  __$$MessagingErrorImplCopyWithImpl(
      _$MessagingErrorImpl _value, $Res Function(_$MessagingErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$MessagingErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MessagingErrorImpl
    with DiagnosticableTreeMixin
    implements MessagingError {
  const _$MessagingErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagingState.error(message: $message)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagingState.error'))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagingErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagingErrorImplCopyWith<_$MessagingErrorImpl> get copyWith =>
      __$$MessagingErrorImplCopyWithImpl<_$MessagingErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ConversationSummary> conversations,
            bool hasMore, int currentPage)
        conversationsLoaded,
    required TResult Function() conversationsCleared,
    required TResult Function(List<Message> messages, bool hasMore,
            int currentPage, int conversationId)
        messagesLoaded,
    required TResult Function(Conversation conversation) conversationCreated,
    required TResult Function(Message message) messageSent,
    required TResult Function(int conversationId, int markedCount)
        messagesMarkedAsRead,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult? Function()? conversationsCleared,
    TResult? Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult? Function(Conversation conversation)? conversationCreated,
    TResult? Function(Message message)? messageSent,
    TResult? Function(int conversationId, int markedCount)?
        messagesMarkedAsRead,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ConversationSummary> conversations, bool hasMore,
            int currentPage)?
        conversationsLoaded,
    TResult Function()? conversationsCleared,
    TResult Function(List<Message> messages, bool hasMore, int currentPage,
            int conversationId)?
        messagesLoaded,
    TResult Function(Conversation conversation)? conversationCreated,
    TResult Function(Message message)? messageSent,
    TResult Function(int conversationId, int markedCount)? messagesMarkedAsRead,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessagingInitial value) initial,
    required TResult Function(MessagingLoading value) loading,
    required TResult Function(MessagingConversationsLoaded value)
        conversationsLoaded,
    required TResult Function(MessagingConversationsCleared value)
        conversationsCleared,
    required TResult Function(MessagesLoaded value) messagesLoaded,
    required TResult Function(ConversationCreated value) conversationCreated,
    required TResult Function(MessageSent value) messageSent,
    required TResult Function(MessagesMarkedAsRead value) messagesMarkedAsRead,
    required TResult Function(MessagingError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessagingInitial value)? initial,
    TResult? Function(MessagingLoading value)? loading,
    TResult? Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult? Function(MessagingConversationsCleared value)?
        conversationsCleared,
    TResult? Function(MessagesLoaded value)? messagesLoaded,
    TResult? Function(ConversationCreated value)? conversationCreated,
    TResult? Function(MessageSent value)? messageSent,
    TResult? Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult? Function(MessagingError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessagingInitial value)? initial,
    TResult Function(MessagingLoading value)? loading,
    TResult Function(MessagingConversationsLoaded value)? conversationsLoaded,
    TResult Function(MessagingConversationsCleared value)? conversationsCleared,
    TResult Function(MessagesLoaded value)? messagesLoaded,
    TResult Function(ConversationCreated value)? conversationCreated,
    TResult Function(MessageSent value)? messageSent,
    TResult Function(MessagesMarkedAsRead value)? messagesMarkedAsRead,
    TResult Function(MessagingError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class MessagingError implements MessagingState {
  const factory MessagingError({required final String message}) =
      _$MessagingErrorImpl;

  String get message;

  /// Create a copy of MessagingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagingErrorImplCopyWith<_$MessagingErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
