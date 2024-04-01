part of 'locale_cubit.dart';

@immutable
class LocaleState {
  final Locale? locale;

  const LocaleState({
    this.locale,
  });

  LocaleState copyWith({
    Locale? locale,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }
}
