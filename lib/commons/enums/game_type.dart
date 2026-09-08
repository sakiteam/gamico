enum GameType {
  adventure("ADVENTURE"),
  remote("REMOTE"),
  passAndPlay("PASS_AND_PLAY"),

  /// Two or more devices playing together over the same WiFi network, one of
  /// them hosting the table. No backend behind it: the host is the authority
  /// and the framework only owns what happens *around* the match (result
  /// bookkeeping, coins, ads, end-of-game popup, "Nouvelle partie").
  localNetwork("LOCAL_NETWORK"),
  tutorial("TUTORIAL");

  final String value;

  const GameType(this.value);
}
