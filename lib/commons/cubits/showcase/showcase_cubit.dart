import 'package:bloc/bloc.dart';

part 'showcase_state.dart';

class ShowcaseCubit extends Cubit<ShowcaseState> {
  ShowcaseCubit() : super(const ShowcaseState());

  void setActive(bool active) {
    emit(state.copyWith(
      active: active,
    ));
  }
}
