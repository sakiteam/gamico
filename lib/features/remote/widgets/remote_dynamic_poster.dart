import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/features/remote/widgets/remote_search_poster.dart';
import 'package:gamico/features/remote/widgets/remote_failure_poster.dart';
import 'package:gamico/features/remote/widgets/remote_new_game_poster.dart';
import 'package:gamico/features/remote/widgets/remote_impossible_game_poster.dart';

class RemoteDynamicPoster extends StatelessWidget {
  final Color? loaderColor;

  const RemoteDynamicPoster({
    super.key,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    final broke = context.select(
            (GamicoUserCubit userCubit) => userCubit.state.user?.broke) ??
        true;

    final status =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.status);
    final finalized = context
        .select((RemoteCubit remoteCubit) => remoteCubit.state.finalized);

    return Center(
      child: status == RemoteGameStatus.failure
          ? const RemoteFailurePoster()
          : finalized
              ? broke
                  ? const RemoteImpossibleGamePoster()
                  : const RemoteNewGamePoster()
              : RemoteSearchPoster(loaderColor: loaderColor),
    );
  }
}
