import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/friend/cubits/friend_invitation_cubit.dart';
import 'package:gamico/features/friend/cubits/invitation_cubit.dart';
import 'package:gamico/features/friend/models/invitation_model.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/providers/gamico_users_provider.dart';
import 'package:gamico/languages/languages.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:gamico/commons/services/notification.dart';

class GamicoFriendPage extends StatefulWidget {
  const GamicoFriendPage({super.key});

  @override
  State<GamicoFriendPage> createState() => _GamicoFriendPageState();
}

class _GamicoFriendPageState extends State<GamicoFriendPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Démarrer l'écoute des invitations
      context.read<InvitationCubit>().startListening(currentUser.uid);

      // Mettre à jour le token de notification
      NotificationService.updateUserToken(UserService.uid);
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(trimmed);
    });
  }

  Future<void> _searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isSearching = true);

    try {
      final usersRef = FirebaseDatabase.instance.ref().child('profiles');

      final simplifiedQuery = removeDiacritics(trimmed.toLowerCase());

      final snapshot = await usersRef
          .orderByChild('formatted_name')
          .startAt(simplifiedQuery)
          .endAt('$simplifiedQuery\uf8ff')
          .limitToFirst(25)
          .get();

      if (!mounted) return;

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        final results = data.entries
            .where((e) => e.key != currentUserId)
            .map(
              (e) => {
                'id': e.key,
                ...Map<String, dynamic>.from(e.value as Map),
              },
            )
            .toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _sendInvitation(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final l = GamicoLanguages.of(context);

    try {
      // Créer l'invitation dans Firebase
      // final invitation =
      await context.read<InvitationCubit>().sendInvitation(
        receiverId,
        UserService.uid,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.friendPageInvitationSent)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.friendPageFailedToSendInvitation)),
      );
    }
  }

  void _navigateToGame({required String gameId, required bool creator}) {
    NavigationService.closePopups();
    NavigationService.pushPageWithAnimation(
      context,
      Gamico.instance.pagesSettings.gamePage(
        context,
        RemoteGameUtility(
          level: null,
          gameId: gameId,
          fakeOpponent: false,
          friend: true,
          remoteUtility: RemoteUtility(
            adventure: false,
            developerAndroidId: "",
            developerAppleId: "",
            levelsBuilder: null,

            matchmakingSettings: MatchmakingSettings(
              minLevel: 0,
              maxLevel: 0,
              getMatchmakingLevel: (_) => 0,
              increment: 0,
            ),
          ),
          adventureUtility: null,
          creatorOfCurrentGame: creator,
          onBackButtonPressed: () async {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: 10 + LayoutService.scaledUsefulSpacing.top,
        ),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(GamicoLanguages.of(context).friendPageTitle),
            leading: const SizedBox(),
            backgroundColor: Colors.transparent,
            actions: [],
          ),
          backgroundColor: Colors.transparent,
          body: BlocListener<InvitationCubit, InvitationState>(
            listener: (context, state) {
              if (state.currentInvitation?.status ==
                  InvitationStatus.accepted) {
                _navigateToGame(
                  gameId: state.currentInvitation!.id,
                  creator: true,
                );

                context.read<InvitationCubit>().nullifyCurrentInvitation();
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: GamicoLanguages.of(context)
                          .friendPageSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(kToolbarHeight),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (_searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];

                        if (user['id'] == UserService.uid) {
                          return const SizedBox();
                        }

                        return BlocBuilder<InvitationCubit, InvitationState>(
                          builder: (context, state) {
                            final bool isInvitationPending =
                                state.currentInvitation != null;
                            final bool isCurrentInvitee =
                                state.currentInvitation?.receiverId ==
                                user['id'];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(user['name'] ?? l.friendPageUnknown),
                              trailing: isCurrentInvitee
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(width: 16),
                                        BlocBuilder<
                                          InvitationCubit,
                                          InvitationState
                                        >(
                                          builder: (context, state) {
                                            if (state.currentInvitation !=
                                                null) {
                                              return ElevatedButton(
                                                child: Text(l.globalCancel),
                                                onPressed: () {
                                                  context
                                                      .read<InvitationCubit>()
                                                      .cancelCurrentInvitation();
                                                },
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.sports_esports,
                                      color: isInvitationPending
                                          ? Colors.grey
                                          : null,
                                    ),
                              onTap: isInvitationPending && !isCurrentInvitee
                                  ? null
                                  : () => _sendInvitation(user['id']),
                              enabled: !isInvitationPending || isCurrentInvitee,
                            );
                          },
                        );
                      },
                    ),
                  ),
                // if (1 == 0)
                BlocBuilder<FriendInvitationCubit, FriendInvitationState>(
                  builder: (context, state) {
                    if (state.pendingInvitations.isEmpty) {
                      return const SizedBox();
                    }

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              GamicoLanguages.of(context)
                                  .friendPagePendingInvitations,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.pendingInvitations.length,
                            itemBuilder: (context, index) {
                              final invitation =
                                  state.pendingInvitations[index];
                              return FutureBuilder(
                                future: GamicoUsersRepository(
                                  usersProvider: GamicoUsersProvider(),
                                  fromJson: (json) => json,
                                  toJson: (user) =>
                                      user as Map<String, dynamic>,
                                ).readUser(invitation.senderId),
                                builder: (context, snapshot) {
                                  return ListTile(
                                    title: Text(l.friendPageGameInvitation),
                                    subtitle: Text(
                                      l.friendPageInvitationFrom(
                                        snapshot.data?['name'] ??
                                            l.friendPageUnknown,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          color: Colors.green,
                                          onPressed: () async {
                                            await context
                                                .read<FriendInvitationCubit>()
                                                .updateInvitationStatus(
                                                  invitation.id,
                                                  InvitationStatus.accepted,
                                                );

                                            _navigateToGame(
                                              gameId: invitation.id,
                                              creator: false,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          color: Colors.red,
                                          onPressed: () => context
                                              .read<FriendInvitationCubit>()
                                              .updateInvitationStatus(
                                                invitation.id,
                                                InvitationStatus.rejected,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    AwesomeNotifications().dispose();
    super.dispose();
  }
}
