import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';

import 'package:gamico/commons/services/gratification.dart';
import 'package:gamico/commons/services/time_zone.dart';

import 'package:flutter/foundation.dart';
import 'package:gamico/commons/settings/gratification_settings.dart';
import 'package:http/http.dart' as http;
import 'package:gamico/commons/services/user.dart';

part 'gratification_state.dart';

class GratificationCubit extends Cubit<GratificationState> {
  static GratificationSettings get gratificationSettings =>
      Gamico.instance.gratificationSettings ?? const GratificationSettings();

  static int get hour1Gratification => gratificationSettings.hour1Gratification;
  static int get hour2Gratification => gratificationSettings.hour2Gratification;
  static int get hour3Gratification => gratificationSettings.hour3Gratification;

  Timer? countdownTimer;
  InternetCubit internetCubit;
  GamicoUserCubit userCubit;

  GratificationCubit({
    required this.userCubit,
    required this.internetCubit,
  }) : super(const GratificationState()) {
    loadWorldDate();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (UserService.authenticated) {
        final gratifiedAt = GratificationService.gratifiedAt ??
            userCubit.state.user?.gratifiedAt ??
            DateTime(2000);
        final now = DateTime.now();
        final gratifiedAtWithoutMinutes = DateTime(gratifiedAt.year,
            gratifiedAt.month, gratifiedAt.day, gratifiedAt.hour);
        final durationDifference = now.difference(gratifiedAtWithoutMinutes);
        final remainingDuration =
            GratificationService.getSpecialOfferRemainingDuration();

        emit(state.copyWith(
          gratificationEnabled: durationDifference.inHours > 0,
          durationDifference: durationDifference,
          offerEnabled: remainingDuration.inSeconds == 0,
          offerRemainingDuration: remainingDuration,
        ));
      }
    });
  }

  void loadWorldDate() async {
    if (internetCubit.state.connected) {
      emit(state.copyWith(loading: true));

      try {
        final response = await http.get(
          Uri.parse(
              "http://worldtimeapi.org/api/timezone/${TimeZoneService.timeZone}"),
        );

        final worldTime = DateTime.tryParse(
                jsonDecode(response.body)["datetime"].toString()) ??
            DateTime.now();

        emit(state.copyWith(
          loading: false,
          worldDateTimeDifference: worldTime.difference(DateTime.now()).abs(),
        ));
      } catch (e) {
        debugPrint(e.toString());

        emit(state.copyWith(
          loading: false,
          worldDateTimeDifference: Duration.zero,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    countdownTimer?.cancel();
    return super.close();
  }
}
