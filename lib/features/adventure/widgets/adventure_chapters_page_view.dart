import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';

class AdventureChaptersPageView extends StatefulWidget {
  final PageController controller;
  final Widget Function(
    BuildContext context,
    int index,
    bool locked,
    int currentIndex,
  )
  itemBuilder;

  final void Function(double page)? onScroll;

  final void Function(int page)? onPageChanged;

  const AdventureChaptersPageView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onScroll,
    this.onPageChanged,
  });

  @override
  State<AdventureChaptersPageView> createState() =>
      _AdventureChaptersPageViewState();
}

class _AdventureChaptersPageViewState extends State<AdventureChaptersPageView> {
  late int _currentIndex = widget.controller.initialPage;

  @override
  Widget build(BuildContext context) {
    final adventureUtility = context.select(
      (GamicoAdventureCubit adventureCubit) =>
          adventureCubit.state.adventureUtility,
    );
    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (widget.controller.hasClients) {
            widget.onScroll?.call(widget.controller.page ?? 0);
          }
        }
        return false;
      },
      child: PageView(
        clipBehavior: Clip.none,
        onPageChanged: (value) {
          setState(() {
            _currentIndex =
                adventureUtility.reversed
                    ? adventureUtility.endChapter - 1 - value
                    : value + adventureUtility.startChapter;
          });
          widget.onPageChanged?.call(value);
        },
        controller: widget.controller,
        children: [
          for (int i = 0;
              i < (adventureUtility.endChapter - adventureUtility.startChapter);
              i++)
            () {
              final globalIndex =
                  adventureUtility.reversed
                      ? (adventureUtility.endChapter - 1 - i)
                      : (adventureUtility.startChapter + i);

              return widget.itemBuilder(
                context,
                globalIndex,
                userLevel <
                    (globalIndex * adventureUtility.levelsPerChapter + 1),
                _currentIndex,
              );
            }(),
        ],
      ),
    );
  }
}
