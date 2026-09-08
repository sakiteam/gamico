import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/utilities/replay_option.dart';
import 'package:gamico/features/game/widgets/game_replay_countdown_dial.dart';
import 'package:gamico/features/game/widgets/game_replay_options_panel.dart';
import 'package:gamico/languages/languages.dart';

/// "Rejouer" at the end of an online match.
///
/// It is a vote, not a request: the button carries how many players are in so
/// far (`Rejouer (2/4)`), tapping it again takes the vote back, and when the
/// game offers choices for the rematch it opens them in a panel anchored just
/// above — where every player watches the others' picks land live. Two players
/// agreeing starts a countdown; the rest of the table is welcome to join it
/// until it runs out.
class GamicoReplayVoteButton extends StatefulWidget {
  /// What the rematch can be played with. Empty means there is nothing to
  /// choose: the button is then a plain ready/cancel toggle.
  final List<GamicoReplayOption> options;

  /// The option currently being played, pre-selected on the first tap so
  /// "Rejouer" stays one tap away when nobody else has voted yet.
  final String? currentOption;

  const GamicoReplayVoteButton({
    super.key,
    this.options = const [],
    this.currentOption,
  });

  @override
  State<GamicoReplayVoteButton> createState() => _GamicoReplayVoteButtonState();
}

class _GamicoReplayVoteButtonState extends State<GamicoReplayVoteButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  OverlayEntry? _entry;

  @override
  void dispose() {
    // The whole popup is going away — drop the panel without animating it out.
    _entry?.remove();
    _entry = null;
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    final remoteGameCubit = context.read<GamicoRemoteGameCubit>();

    if (widget.options.isEmpty) {
      remoteGameCubit.voteReplay();
      return;
    }

    if (_entry != null) {
      _closeOverlay();
      return;
    }

    if (remoteGameCubit.myReplayVote == null) {
      // Pre-select what is being played only while nobody else has voted.
      // Once an opponent has picked something, defaulting away from what they
      // are waiting on would be worse than making the choice deliberate.
      final anyoneElseVoted = remoteGameCubit.state.replayVotes.keys.any(
        (id) => id != LocalStorageService.uid,
      );
      final current = widget.currentOption;
      if (!anyoneElseVoted && current != null) {
        remoteGameCubit.voteReplay(current);
      }
    }

    _openOverlay(remoteGameCubit);
  }

  void _openOverlay(GamicoRemoteGameCubit remoteGameCubit) {
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final anchorRect = box.localToGlobal(Offset.zero) & box.size;

    _entry = OverlayEntry(
      builder: (_) => BlocProvider.value(
        value: remoteGameCubit,
        child: _ReplayVoteOverlay(
          anchorRect: anchorRect,
          animation: _animCtrl,
          options: widget.options,
          onDismiss: _closeOverlay,
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
    _animCtrl.forward();
  }

  Future<void> _closeOverlay() async {
    if (_entry == null) return;
    await _animCtrl.reverse();
    if (!mounted) return;
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final remoteGameCubit = context.watch<GamicoRemoteGameCubit>();
    final state = remoteGameCubit.state;

    final possible = state.replayVotePossible;
    final myVote = remoteGameCubit.myReplayVote;
    final isReady = possible && myVote != null;

    final label = widget.options
        .where((option) => option.id == myVote)
        .map((option) => option.label)
        .firstOrNull;

    return GamicoIconTextButton(
      key: _buttonKey,
      iconData: isReady ? Icons.check_circle : Icons.refresh,
      text: possible
          ? "${label ?? l.gamePopupReplay}"
                " (${state.replayReadyCount}/${state.replayTotalCount})"
          : l.gamePopupReplay,
      color: isReady ? ColorService.accentColor : null,
      // Replaying takes the same players: once everyone else has left there is
      // nobody to play, and only "Nouvelle partie" remains.
      onPressed: possible ? _handleTap : null,
    );
  }
}

/// The options panel, floating just above the button with an arrow pointing
/// back at it. Stays open after a pick so the other players' votes keep
/// landing in view; a tap outside closes it.
class _ReplayVoteOverlay extends StatelessWidget {
  final Rect anchorRect;
  final Animation<double> animation;
  final List<GamicoReplayOption> options;
  final VoidCallback onDismiss;

  const _ReplayVoteOverlay({
    required this.anchorRect,
    required this.animation,
    required this.options,
    required this.onDismiss,
  });

  static const double _gap = 8;
  static const double _arrowWidth = 32;
  static const double _arrowHeight = 16;
  static const double _sideMargin = 32;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final panelWidth = screen.width - _sideMargin * 2;

    final arrowLeft = (anchorRect.center.dx - _sideMargin - _arrowWidth / 2)
        .clamp(12.0, math.max(12.0, panelWidth - _arrowWidth - 12.0))
        .toDouble();

    return Stack(
      children: [
        // Tap-outside barrier, below the panel so taps on it reach the cards.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: _sideMargin,
          right: _sideMargin,
          bottom: screen.height - anchorRect.top + _gap,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              alignment: Alignment.bottomCenter,
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeIn,
              ),
              child: BlocBuilder<GamicoRemoteGameCubit, GamicoRemoteGameState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.replayCountdownStartedAt != null) ...[
                        GamicoReplayCountdownDial(
                          startedAt: state.replayCountdownStartedAt,
                          duration: GamicoRemoteGameCubit.replayCountdown,
                        ),
                        const SizedBox(height: 8),
                      ],
                      GamicoReplayOptionsPanel(options: options, opaque: true),
                      Padding(
                        padding: EdgeInsets.only(left: arrowLeft),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomPaint(
                            size: const Size(_arrowWidth, _arrowHeight),
                            painter: const _ArrowPainter(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF15171C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
