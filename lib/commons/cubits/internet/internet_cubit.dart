import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  StreamSubscription? subscription;
  final SimpleConnectionChecker _simpleConnectionChecker =
      SimpleConnectionChecker();

  InternetCubit() : super(const InternetState(connected: true)) {
    subscription =
        _simpleConnectionChecker.onConnectionChange.listen((connected) {
      emit(state.copyWith(connected: connected));
    });
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
