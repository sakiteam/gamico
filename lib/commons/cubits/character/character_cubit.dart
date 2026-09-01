import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gamico/commons/global/gamico.dart';

import 'package:meta/meta.dart';
import 'package:gamico/commons/enums/character_position.dart';
import 'package:flame/components.dart' as flame_components;

part 'character_state.dart';

enum FeelingType { sad, happy, normal, anxious }

class CharacterCubit extends Cubit<CharacterState> {
  Timer? _timer;
  final List<List<GamicoCharacterPosition>> _positionsListList = [];

  bool _blocking = false;

  List<flame_components.Sprite> sadList = [];
  List<flame_components.Sprite> happyList = [];
  List<flame_components.Sprite> normalList = [];
  List<flame_components.Sprite> anxiousList = [];

  flame_components.SpriteAnimation? sadSpriteAnimation;
  flame_components.SpriteAnimation? happySpriteAnimation;
  flame_components.SpriteAnimation? normalSpriteAnimation;
  flame_components.SpriteAnimation? anxiousSpriteAnimation;

  // List<flameComponents.SpriteAnimation?> get animations => [
  //       sadSpriteAnimation,
  //       happySpriteAnimation,
  //       normalSpriteAnimation,
  //       anxiousSpriteAnimation
  //     ];

  CharacterCubit() : super(const CharacterState()) {
    init();
  }

  void init() async {
    try {
      await Future.wait([
        _fillList(sadList, "sad"),
        _fillList(happyList, "happy"),
        _fillList(normalList, "normal"),
        _fillList(anxiousList, "anxious"),
      ]);

      if (sadList.isNotEmpty) {
        sadSpriteAnimation = flame_components.SpriteAnimation.spriteList(
          sadList,
          stepTime: 0.125,
        );
      }
      if (happyList.isNotEmpty) {
        happySpriteAnimation = flame_components.SpriteAnimation.spriteList(
          happyList,
          stepTime: 0.125,
        );
      }
      if (normalList.isNotEmpty) {
        normalSpriteAnimation = flame_components.SpriteAnimation.spriteList(
          normalList,
          stepTime: 0.125,
        );
      }
      if (anxiousList.isNotEmpty) {
        anxiousSpriteAnimation = flame_components.SpriteAnimation.spriteList(
          anxiousList,
          stepTime: 0.125,
        );
      }

      emit(
        state.copyWith(
          position: state.position,
          animation: normalSpriteAnimation,
        ),
      );
    } catch (_) {}

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_blocking) {
        setPosition();
      }
    });
  }

  void setFeeling(FeelingType feeling) {
    // for (final  animation in animations) {
    //   animation?.totalDuration()
    // }

    double elapsed = state.animation?.createTicker().elapsed ?? 0;

    flame_components.SpriteAnimation? activeAnimation;

    switch (feeling) {
      case FeelingType.sad:
        activeAnimation = sadSpriteAnimation;
        break;

      case FeelingType.happy:
        activeAnimation = happySpriteAnimation;
        break;

      case FeelingType.normal:
        activeAnimation = normalSpriteAnimation;
        break;

      case FeelingType.anxious:
        activeAnimation = anxiousSpriteAnimation;
        break;
    }

    final activeAnimationTicker = activeAnimation?.createTicker();

    activeAnimationTicker?.reset();
    activeAnimationTicker?.update(elapsed);

    emit(state.copyWith(animation: activeAnimation, position: state.position));
  }

  Future<void> _fillList(
    List<flame_components.Sprite> spritesList,
    String name,
  ) async {
    spritesList.clear();

    for (int i = 1; i <= 30; i++) {
      int index = i <= 26 ? ((i == 10 || i == 20) ? 10 : (i % 10)) : i - 16;
      String n = index < 10 ? "0$index" : "$index";
      try {
        spritesList.add(
          await flame_components.Sprite.load(
            "${Gamico.instance.characterSettings?.name}/$name/$n.png",
          ),
        );
      } catch (_) {}
    }
  }

  void setPosition() async {
    if (_positionsListList.isNotEmpty) {
      final positions = List<GamicoCharacterPosition>.from(
        _positionsListList.last,
      );
      positions.shuffle();

      if (positions.isNotEmpty) {
        emit(state.copyWith(position: positions.first));
      } else {
        emit(state.copyWith(position: null));
      }
    } else {
      emit(state.copyWith(position: null));
    }
  }

  void nullifyPosition() async {
    _blocking = true;

    emit(state.copyWith(position: null));

    await Future.delayed(const Duration(seconds: 3));

    _blocking = false;
  }

  void upsertPositionsList(List<GamicoCharacterPosition> positions) async {
    final i = _positionsListList.indexOf(positions);

    if (i < 0) {
      _positionsListList.add(positions);
    } else {
      _positionsListList[i] = positions;
    }

    // await GlobalService.waitWhile(() => !setting);

    if (!positions.contains(state.position)) {
      // setPosition();
      nullifyPosition();
    }
  }

  void deletePositionsList(List<GamicoCharacterPosition> positions) async {
    _positionsListList.remove(positions);

    // await GlobalService.waitWhile(() => !setting);

    if (_positionsListList.isNotEmpty) {
      if (!_positionsListList.last.contains(state.position)) {
        // setPosition();
        nullifyPosition();
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
