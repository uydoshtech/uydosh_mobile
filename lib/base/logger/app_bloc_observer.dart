import "package:bloc/bloc.dart";
import "package:flutter/foundation.dart";
import "package:uy_dosh/base/logger/logger.dart";

class AppBlocObserver extends BlocObserver {
  AppBlocObserver._();
  factory AppBlocObserver.instance() => _singleton ??= AppBlocObserver._();
  static AppBlocObserver? _singleton;

  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);
    logger.d("${bloc.runtimeType}()");
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event == null) return;
    logger.d("${bloc.runtimeType}.add(${event.runtimeType})");
    final Object? state = bloc.state;
    if (state == null) return;
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      final Object? event = transition.event;
      final Object? currentState = transition.currentState;
      final Object? nextState = transition.nextState;
      if (event == null || currentState == null || nextState == null) return;
      logger.d(
        "${bloc.runtimeType} ${event.runtimeType}: ${currentState.runtimeType}->${nextState.runtimeType}",
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e("BLoC: ${bloc.runtimeType}", error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase<Object?> bloc) {
    super.onClose(bloc);
    logger.d("${bloc.runtimeType}.close()");
  }
}
