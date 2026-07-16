// import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:gamico/commons/basico/services/generic_global.dart';
// import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
// import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:meta/meta.dart';
// import 'package:simple_connection_checker/simple_connection_checker.dart';

part 'referral_state.dart';

class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit(
    // {
    // required this.authenticationCubit,
    // required this.internetCubit,
    // }
  ) : super(const ReferralState()) {
    // if (UserService.authenticated) {
    //   () async {
    //     _generateLink(await SimpleConnectionChecker.isConnectedToInternet());
    //   }();
    // }

    // _subscription =
    //     authenticationCubit.stream.listen((authenticationState) async {
    //   if (_authenticated != authenticationState.authenticated) {
    //     _authenticated = authenticationState.authenticated;

    //     if (_authenticated) {
    //       _generateLink(await SimpleConnectionChecker.isConnectedToInternet());
    //     } else {
    //       _emitLink("");
    //     }
    //   }
    // });

    // _internetSubscription = internetCubit.stream.listen((event) {
    //   if (event.connected && UserService.authenticated) {
    //     _generateLink();
    //   }
    // });
  }

  // final AuthenticationCubit authenticationCubit;
  // final InternetCubit internetCubit;

  // StreamSubscription<AuthenticationState>? _subscription;
  // StreamSubscription<InternetState>? _internetSubscription;

  // String _link = "";
  // bool _authenticated = UserService.authenticated;

  // void _emitLink(String link) {
  //   emit(state.copyWith(
  //     link: link,
  //   ));
  // }

  // void _generateLink([bool connected = true]) async {
  //   if (_link.isEmpty && connected) {
  //     emit(state.copyWith(
  //       status: ReferralStatus.loading,
  //     ));

  //     try {
  //       final DynamicLinkParameters parameters = DynamicLinkParameters(
  //         uriPrefix: 'https://tactico.page.link',
  //         link: Uri.parse(
  //           'https://saki-hub.web.app?referrer_id=${UserService.uid}',
  //         ),
  //         androidParameters: const AndroidParameters(
  //           packageName: "com.saki.tactico",
  //           minimumVersion: 1,
  //         ),
  //         iosParameters: const IOSParameters(
  //           bundleId: "com.saki.tactico",
  //           minimumVersion: '1',
  //         ),
  //       );

  //       final ShortDynamicLink shortDynamicLink =
  //           await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  //       final Uri uri = shortDynamicLink.shortUrl;

  //       _link = uri.toString();
  //     } catch (e) {
  //       emit(state.copyWith(
  //         status: ReferralStatus.failure,
  //       ));
  //     }
  //   }

  //   _emitLink(_link);
  // }

  // @override
  // Future<void> close() {
  //   _subscription?.cancel();
  //   _internetSubscription?.cancel();

  //   return super.close();
  // }
}
