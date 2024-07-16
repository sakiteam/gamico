import 'package:bloc/bloc.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:meta/meta.dart';

part 'adventure_state.dart';

class GamicoAdventureCubit extends Cubit<GamicoAdventureState> {
  GamicoAdventureCubit({
    required AdventureUtility adventureUtility,
    required RemoteUtility? remoteUtility,
  }) : super(GamicoAdventureState(
          adventureUtility: adventureUtility,
          remoteUtility: remoteUtility,
        ));

  void init() {
    setAnimInit(true);
  }

  void setAnimInit(bool animInit) {
    emit(state.copyWith(
      animInit: animInit,
    ));
  }

  void setAnimGame(bool animGame) {
    emit(state.copyWith(
      animGame: animGame,
    ));
  }

  void setAnimated(bool animated) {
    emit(state.copyWith(
      animated: animated,
    ));
  }
}
