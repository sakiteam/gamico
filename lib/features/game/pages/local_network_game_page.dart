import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/local_network/local_network_game_cubit.dart';

/// Shell of a WiFi-local match: counts the table towards the app-wide ad
/// cadence and turns a "Nouvelle partie" request into the host app actually
/// dealing one.
class LocalNetworkGamePage extends StatefulWidget {
  final Widget child;
  final LocalNetworkGameUtility gameUtility;

  const LocalNetworkGamePage({
    super.key,
    required this.child,
    required this.gameUtility,
  });

  @override
  State<LocalNetworkGamePage> createState() => _LocalNetworkGamePageState();
}

class _LocalNetworkGamePageState extends State<LocalNetworkGamePage> {
  @override
  void initState() {
    super.initState();

    // Same counter every other mode of the app feeds: a LAN table is a played
    // game like any other, it just has no backend to count it.
    LocalStorageService.games++;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      GamicoLocalNetworkGameCubit,
      GamicoLocalNetworkGameState
    >(
      listenWhen: (previous, current) =>
          !previous.newGameActive && current.newGameActive,
      listener: (context, state) {
        final localNetworkCubit = context.read<GamicoLocalNetworkGameCubit>();

        // Clear the match flags first: the host app deals the new match
        // synchronously, and its first state must land on a clean slate.
        localNetworkCubit.resetForNewGame();

        widget.gameUtility.onNewGame?.call();
      },
      child: widget.child,
    );
  }
}
