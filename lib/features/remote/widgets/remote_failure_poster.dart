import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';

class RemoteFailurePoster extends StatelessWidget {
  const RemoteFailurePoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final animInit =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animInit);
    final animGame =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animGame);

    return GamicoPoster(
      animationTarget: animInit && !animGame ? 1 : 0,
      icon: Icons.error,
      title: l.remoteFailurePosterTitle,
      description: l.remoteFailurePosterDescription,
      content: GamicoIconTextButton(
        onPressed: () {
          context.read<RemoteCubit>().reset();
        },
        backgroundColor: Colors.brown,
        color: Colors.brown.shade300,
        text: null,
        iconData: Icons.refresh,
      ),
    );
  }
}
