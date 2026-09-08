import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/locale/locale_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/cubits/referral/referral_cubit.dart';
import 'package:gamico/commons/cubits/showcase/showcase_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/providers/gamico_games_provider.dart';
import 'package:gamico/commons/providers/gamico_purchases_provider.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/repositories/gamico_purchases_repository.dart';
import 'package:gamico/features/friend/cubits/friend_invitation_cubit.dart';

/// Injects all core Gamico repositories and BLoCs/Cubits into the widget tree.
class GamicoProviders extends StatelessWidget {
  final LocaleCubit localeCubit;
  final Widget child;

  const GamicoProviders({
    super.key,
    required this.localeCubit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: Gamico.instance.usersRepository),
        RepositoryProvider(
          create: (context) =>
              GamicoGamesRepository(gamesProvider: GamicoGamesProvider()),
        ),
        RepositoryProvider(
          create: (context) => GamicoPurchasesRepository(
            purchasesProvider: GamicoPurchasesProvider(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => FriendInvitationCubit(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => GamicoUserCubit(
              usersRepository: Gamico.instance.usersRepository,
            ),
          ),
          BlocProvider(lazy: false, create: (context) => GamicoMusicCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => AuthenticationCubit(
              onAuthenticated: () =>
                  context.read<FriendInvitationCubit>().listenToInvitations(),
              userCubit: context.read<GamicoUserCubit>(),
              usersRepository: Gamico.instance.usersRepository,
            ),
          ),
          BlocProvider(lazy: false, create: (context) => InternetCubit()),
          BlocProvider(
            lazy: false,
            create: (context) =>
                AdmobCubit(userCubit: context.read<GamicoUserCubit>()),
          ),
          BlocProvider(lazy: false, create: (context) => ShowcaseCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => PurchasesCubit(
              userCubit: context.read<GamicoUserCubit>(),
              purchasesRepository: context.read<GamicoPurchasesRepository>(),
            ),
          ),
          BlocProvider(lazy: false, create: (context) => ReferralCubit()),
          BlocProvider(lazy: false, create: (context) => CharacterCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => GratificationCubit(
              userCubit: context.read<GamicoUserCubit>(),
              internetCubit: context.read<InternetCubit>(),
            ),
          ),
          BlocProvider.value(value: localeCubit),
        ],
        child: child,
      ),
    );
  }
}
