import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/locale.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState());

  void setLocale(Locale locale) {
    LocaleService.currentLocale = locale;
    LocaleService.language = locale.languageCode;

    emit(state.copyWith(
      locale: locale,
    ));
  }
}
