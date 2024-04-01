import 'package:bloc/bloc.dart';

class GamicoDecorationCubit<T> extends Cubit<T> {
  final T t;

  GamicoDecorationCubit(this.t) : super(t);

  final List<T> _positionsList = [];

  void setDecoration(T s) {
    emit(s);
  }

  void upsertPositionsList(T oldState, T newState) async {
    final i = _positionsList.indexOf(oldState);

    if (i < 0) {
      _positionsList.add(newState);
    } else {
      _positionsList[i] = newState;
    }

    setDecoration(newState);
  }

  void deleteState(T positions) async {
    _positionsList.remove(positions);

    // await GlobalService.waitWhile(() => !setting);

    // if (_positionsListList.isNotEmpty) {
    //   if (!_positionsListList.last.contains(state.position)) {
    //     // setPosition();
    //     nullifyPosition();
    //   }
    // }

    if (_positionsList.isNotEmpty) {
      setDecoration(_positionsList.last);
    } else {
      setDecoration(t);
    }
  }
}
