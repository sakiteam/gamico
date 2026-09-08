import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageEs extends GamicoLanguages {
  @override
  String get globalMax => "MÁX";
  @override
  String get globalRefresh => "Actualizar";
  @override
  String get globalClose => "Cerrar";
  @override
  String get globalOK => "Aceptar";

  /* FRIEND */

  @override
  String get friendPageTitle => "Buscar amigos";

  @override
  String get friendPageSearchHint => "Buscar por nombre...";

  @override
  String get friendPagePendingInvitations => "Invitaciones pendientes";

  @override
  String get friendPageGameInvitation => "Invitación al juego";

  @override
  String friendPageInvitationFrom(String name) => "De: $name";

  @override
  String get friendPageInvitationSent => "¡Invitación enviada!";

  @override
  String get friendPageFailedToSendInvitation =>
      "Error al enviar la invitación";

  @override
  String get friendPageUnknown => "Desconocido";
  @override
  String get notificationInvitationBody =>
      "¡Has recibido una invitación para jugar!";
  @override
  String notificationInvitationFrom(String name) => "¡$name te invita a jugar!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Ayuda";
  @override
  String get adventureHelpDescription =>
      "Puede seleccionar un nivel haciendo clic en él. ¡Pero si aún no sabe jugar bien, siga el tutorial!";
  @override
  String get adventureClose => "Cerrar";
  @override
  String get adventureFollow => "Seguir";

  @override
  String adventureChapterChapter(int chapter) => "Capítulo $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Familia: $family";
  @override
  String get collectionCardPopupUpgrade => "Mejorar";
  @override
  String get collectionCardPopupRemove => "Quitar";
  @override
  String get collectionCardPopupUse => "Usar";
  @override
  String get collectionCardPopupAcquire => "Adquirir";

  @override
  String get collectionCardSkillsAttack => "Ataque";
  @override
  String get collectionCardSkillsSupport => "Apoyo";
  @override
  String get collectionCardSkillsResistance => "Resistencia";
  @override
  String get collectionCardSkillsTheoreticalLife => "Vida Teórica";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "Velocidad Teórica";
  @override
  String get collectionCardSkillsPower => "Poder";
  @override
  String get collectionCardSkillsConcreteLife => "Vida Concreta";
  @override
  String get collectionCardSkillsConcreteSpeed => "Velocidad Concreta";
  @override
  String get collectionCardSkillsConnections => "Conexiones";

  @override
  String collectionCardSquareLevel(int level) => "Nivel $level";

  @override
  String get collectionCardBlocked => "Bloqueado";
  @override
  String collectionCardLevel(int level) => "Nivel $level";

  @override
  String get collectionContentDeck => "Mazos";
  @override
  String get collectionContentUnlockedCards => "Cartas desbloqueadas";
  @override
  String get collectionContentRemainingCards => "Cartas restantes";

  /* HOME */

  @override
  String get homeLanguagesTitle => "Idiomas";

  @override
  String get homeMultiplayerButtonShowcase =>
      "Este botón te permite jugar partidas con otros jugadores en línea.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "Este botón te permite jugar partidas con la inteligencia artificial del juego.";
  @override
  String get homeNotificationsTitle => "Notificaciones";
  @override
  String get homeNotificationsDescription =>
      "Para mejorar tu experiencia de juego, debes habilitar las notificaciones. ¿Deseas permitir las notificaciones?";
  @override
  String get homeNotificationsAllow => "Permitir";
  @override
  String get homeNotificationsReminderTitle => "Activar notificaciones";
  @override
  String get homeNotificationsReminderDescription =>
      "Las notificaciones son importantes para una mejor experiencia de juego. ¿Quieres activarlas ahora?";
  @override
  String get homeUpdateTitle => "¡Actualización disponible!";
  @override
  String get homeUpdateForceDescription =>
      "Se han resuelto varios errores y problemas en la nueva versión. ¡Instálala rápidamente para aprovechar estas correcciones!";
  @override
  String get homeUpdateInstall => "Instalar";

  @override
  String get homeAbout => "Acerca de";
  @override
  String homeAboutPopupShareText(String link) =>
      "¡He descubierto un juego de estrategia muy interesante! Descárgalo gratis en $link!";
  @override
  String get homeAboutPopupImplementation => "Implementación";
  @override
  String get homeAboutPopupMusic => "Música";
  @override
  String get homeAboutPopupVersion => "Versión";
  @override
  String get homeAboutPopupRateGame => "Calificar\nel juego";
  @override
  String get homeAboutPopupVisitWebstie => "Visitar\nSaki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "Ver mis\naplicaciones";

  @override
  String get homeCardPresentationShowcase =>
      "Utiliza este menú para comprar nuevas cartas y mejorar las que ya tienes.";
  @override
  String get homeCardPresentationShow => "Ver todas las cartas";

  @override
  String get homeGratificationPopupConnectionErrorTitle =>
      "¡Error de conexión!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Por favor, verifica tu conexión a internet. ¡Esta sección se actualizará automáticamente cuando te conectes!";
  @override
  String get homeGratificationPopupLoadingTitle => "Cargando recompensas!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "Las recompensas estarán disponibles en solo unos segundos. ¡Por favor, espera!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Marca de tiempo incorrecta!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle =>
      "Problema de Conexión!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "Parece que no estás conectado a Internet. Por favor, verifica la calidad de tu conexión a Internet y vuelve a intentarlo!";
  @override
  String get homeMultiplayerButtonText => "Multi";

  @override
  String get homeProfilePopupBestTacticians => "Mejores Tácticos";
  @override
  String get homeProfilePopupDescription =>
      "Los jugadores se clasifican en función de dos criterios: el número de victorias en línea y el número máximo de cauris!";
  @override
  String get homeProfilePopupBestCollectors => "Mejores Coleccionistas";
  @override
  String get homeProfilePopupCheckAchievements => "Ver Mis Logros";

  @override
  String get homeSingleplayerButtonText => "Solitario";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "Las ofertas especiales se activan cada 3 días y solo son válidas durante 24 horas. ¡No te pierdas la próxima!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "Las ofertas especiales se activan cada 3 días y solo son válidas durante 24 horas. ¿A qué estás esperando?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Los datos relacionados con la oferta especial estarán disponibles en breve. ¡Por favor, espera un momento!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "No pudimos validar tu compra. ¡Por favor, verifica tu método de pago y tu conexión a Internet!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "Cargando Oferta!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Transacción Cancelada!";
  @override
  String get homeSpecialOfferPopupClose => "Cerrar";
  @override
  String get homeSpecialOfferPopupTimestampTitle =>
      "Sello de Tiempo Incorrecto!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Los datos relacionados con la oferta especial estarán disponibles en breve. ¡Por favor, espera un momento!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Cargando Oferta!";
  @override
  String get homeSpecialOfferPopupProblemClose => "Cerrar";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Error de Conexión!";

  @override
  String get premiumPopupTitle => "Modo Premium";
  @override
  String get premiumPopupDescription =>
      "¡Desbloquea la versión completa para eliminar todos los anuncios!";
  @override
  String get premiumPlayer => "Jugador Premium";
  @override
  String get nonPremiumPlayer => "Jugador no premium";

  @override
  String get homeHelpBasicsA =>
      "El reino de los Azules se enfrenta al reino de los Naranjas.";
  @override
  String get homeHelpBasicsB =>
      "Se puede ganar cambiando el color del señor enemigo.";
  @override
  String get homeHelpBasicsC =>
      "Se puede ganar teniendo la mayor cantidad de puntos de vida en el tiempo asignado.";

  @override
  String get homeHelpConnections1A =>
      "Puedes tocar y arrastrar para conectar dos cartas.";
  @override
  String get homeHelpConnections1B =>
      "Puedes tocar y tocar para conectar dos cartas.";
  @override
  String get homeHelpConnections1C =>
      "Puedes cortar una conexión deslizando un dedo.";

  @override
  String get homeHelpConnections2A =>
      "Una conexión a veces puede obstaculizar la capacidad de jugar.";
  @override
  String get homeHelpConnections2B =>
      "No es posible saltar una carta para conectar con otra.";
  @override
  String get homeHelpConnections2C =>
      "Una carta en MAX devuelve todas las bolas que recibe.";

  @override
  String get homeHelpCards1A => "Las cartas rojas son buenas en el ataque.";
  @override
  String get homeHelpCards1B => "Las cartas grises son buenas en la defensa.";
  @override
  String get homeHelpCards1C => "Las cartas verdes son buenas en el apoyo.";

  @override
  String get homeHelpCards2A =>
      "Las cartas marrones tienen habilidades equilibradas.";
  @override
  String get homeHelpCards2B =>
      "Las cartas amarillas tienen efectos especiales en otras cartas.";
  @override
  String get homeHelpCards2C =>
      "Las cartas blancas son las que deben protegerse a toda costa.";

  @override
  String get homeHelpRestrictionsA =>
      "Cada conexión debe ser útil. Aquí es inútil y, por lo tanto, imposible.";
  @override
  String get homeHelpRestrictionsB =>
      "Una carta de destrucción no puede atacar a un señor.";
  @override
  String get homeHelpRestrictionsC =>
      "No es posible clonar o mover a un señor.";

  /* LOADING */

  @override
  String get loadingTitle => "Por favor, espere!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Problema de conexión!";
  @override
  String get remoteConnexionProblemDescription =>
      "¡Lo siento! Su conexión a Internet se ha desconectado. ¡Has sido declarado perdedor del juego!";
  @override
  String get remoteInvitationTitle => "¡Ven y juega!";
  @override
  String get remoteInvitationDescription => "Tu juego en línea ha comenzado!";
  @override
  String get remoteMultiplayer => "Multijugador";

  @override
  String get remoteFailurePosterTitle => "¡Ha ocurrido un error!";
  @override
  String get remoteFailurePosterDescription =>
      "Se produjo un error durante la búsqueda. ¡Verifique su conexión a Internet y vuelva a intentarlo!";

  @override
  String get remoteImpossibleGamePosterTitle => "¡Cauris insuficientes!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "Necesitas al menos $cowries cauris para jugar en línea!";

  @override
  String get remoteNewGamePosterTitle => "¿Un juego nuevo?";
  @override
  String get remoteNewGamePosterDescription =>
      "Todavía puedes jugar con jugadores de todo el mundo para mejorar tu nivel!";

  @override
  String get remoteSearchPosterTitle => "Búsqueda de jugadores";
  @override
  String get remoteSearchPosterDescription =>
      "Estamos buscando jugadores en todo el mundo para jugar contigo!";
  @override
  String get homeTranslationPopupDescription =>
      "Esta sección te permite elegir el idioma principal del juego. ¡Haz clic en un idioma para activarlo automáticamente!";

  /* TÍTULOS DE LAS CARTAS */

  @override
  String get lordLazyKingName => "Rey Perezoso";
  @override
  String get lordLazyQueenName => "Reina Frágil";
  @override
  String get lordLazyPrinceName => "Príncipe Solitario";
  @override
  String get lordLazyPrincessName => "Princesa Introvertida";
  @override
  String get lordCourageousKingName => "Rey Pragmático";
  @override
  String get lordCourageousQueenName => "Reina Intrépida";
  @override
  String get lordCourageousPrinceName => "Príncipe Resistente";
  @override
  String get lordCourageousPrincessName => "Princesa Devota";
  @override
  String get normalOrdinaryCitizenName => "Ciudadano Ordinario";
  @override
  String get normalAttackerDefenderName => "Guardia Militar";
  @override
  String get normalAttackerHealerName => "Sanitario Militar";
  @override
  String get normalDefenderHealerName => "Guardia Sanitario";
  @override
  String get attacker2AName => "Gripe";
  @override
  String get attacker2BName => "Sol";
  @override
  String get attacker2CName => "Chispa";
  @override
  String get attacker4AName => "Remolino";
  @override
  String get attacker4BName => "Mosquito";
  @override
  String get attacker4CName => "Ciclón";
  @override
  String get defender2AName => "Roca";
  @override
  String get defender2BName => "Guijarro";
  @override
  String get defender2CName => "Rampa";
  @override
  String get defender4AName => "Rayo";
  @override
  String get defender4BName => "Balcón";
  @override
  String get defender4CName => "Ventana";
  @override
  String get healer2AName => "Hierba";
  @override
  String get healer2BName => "Flor";
  @override
  String get healer2CName => "Hoja";
  @override
  String get healer4AName => "Arbusto";
  @override
  String get healer4BName => "Vendaje";
  @override
  String get healer4CName => "Árbol";
  @override
  String get specialExpansionName => "Expansión";
  @override
  String get specialCompressionName => "Compresión";
  @override
  String get specialDecelerationName => "Desaceleración";
  @override
  String get specialAccelerationName => "Aceleración";
  @override
  String get specialAttackIncreaseName => "Valentía";
  @override
  String get specialAttackDecreaseName => "Cobardía";
  @override
  String get specialResistanceIncreaseName => "Fortalecimiento";
  @override
  String get specialResistanceDecreaseName => "Debilitamiento";
  @override
  String get specialSupportIncreaseName => "Altruismo";
  @override
  String get specialSupportDecreaseName => "Individualismo";
  @override
  String get specialCloningName => "Clonación";
  @override
  String get specialCancellationName => "Cancelación";
  @override
  String get specialRefrigerationName => "Refrigeración";
  @override
  String get specialAspiratorName => "Abismo";
  @override
  String get specialSubstractionName => "Sustracción";
  @override
  String get specialDivisionName => "División";
  @override
  String get specialDeflagrationName => "Deflagración";
  @override
  String get specialParalysisName => "Parálisis";
  @override
  String get specialInvulnerabilityName => "Invulnerabilidad";
  @override
  String get specialVortexName => "Vórtice";

  /* DESCRIPCIONES DE LAS CARTAS */

  @override
  String get lordLazyKingDescription =>
      "Este es el único señor que no puede atacar ni defender. Pero es un rey equilibrado sin debilidades particulares.";
  @override
  String get lordLazyQueenDescription =>
      "Ella es una dama muy hábil para atacar y apoyar a sus súbditos a pesar de su avanzada edad. Sin embargo, su resistencia deja mucho que desear.";
  @override
  String get lordLazyPrinceDescription =>
      "Él es un joven muy hábil para atacar y resistir los ataques. Sin embargo, no sabe cómo apoyar a sus súbditos.";
  @override
  String get lordLazyPrincessDescription =>
      "Ella es una joven muy hábil para resistir ataques y apoyar a sus súbditos. Sin embargo, no es fuerte en el ataque.";
  @override
  String get lordCourageousKingDescription =>
      "Este es un rey equilibrado sin debilidades particulares. Sin embargo, ¡tiene la mitad de puntos de vida que lo normal!";
  @override
  String get lordCourageousQueenDescription =>
      "Ella es una dama extremadamente hábil para atacar a pesar de su avanzada edad. Pero no destaca en otras áreas.";
  @override
  String get lordCourageousPrinceDescription =>
      "Él es un joven extremadamente hábil para resistir los ataques. Pero este príncipe no destaca en otras áreas.";
  @override
  String get lordCourageousPrincessDescription =>
      "Ella es una joven extremadamente hábil para apoyar a sus súbditos. Pero esta princesa no destaca en otras áreas.";
  @override
  String get normalOrdinaryCitizenDescription =>
      "Esta carta es la más equilibrada del juego. No tiene ni fortalezas especiales ni debilidades especiales, ¡pero sigue siendo un aliado confiable!";
  @override
  String get normalAttackerDefenderDescription =>
      "Como su nombre indica, es un joven hábil para atacar a sus enemigos mientras resiste sus ataques.";
  @override
  String get normalAttackerHealerDescription =>
      "Como su nombre indica, es un joven hábil para atacar a sus enemigos mientras apoya a sus aliados.";
  @override
  String get normalDefenderHealerDescription =>
      "Como su nombre indica, es un joven hábil para apoyar a sus aliados mientras resiste los ataques de sus enemigos.";
  @override
  String get attacker2ADescription =>
      "Esta carta inflige el doble de daño a sus enemigos en comparación con una carta normal, pero no es muy buena para apoyar a sus aliados.";
  @override
  String get attacker2BDescription =>
      "Esta carta inflige el doble de daño a sus enemigos en comparación con una carta normal, pero es débil contra los ataques de sus enemigos.";
  @override
  String get attacker2CDescription =>
      "Esta carta inflige el doble de daño a sus enemigos en comparación con una carta normal, pero es el doble de lenta que una carta normal.";
  @override
  String get attacker4ADescription =>
      "Esta carta inflige cuatro veces más daño a sus enemigos que una carta normal, pero no es muy buena para apoyar a sus aliados.";
  @override
  String get attacker4BDescription =>
      "Esta carta inflige cuatro veces más daño a sus enemigos que una carta normal, pero es muy débil contra los ataques de sus enemigos.";
  @override
  String get attacker4CDescription =>
      "Esta carta inflige cuatro veces más daño a sus enemigos que una carta normal, pero no destaca en otras áreas.";
  @override
  String get defender2ADescription =>
      "Esta carta tiene una resistencia dos veces mayor que la normal, pero no es muy buena para atacar a sus enemigos.";
  @override
  String get defender2BDescription =>
      "Esta carta tiene una resistencia dos veces mayor que la normal, pero no es muy buena para apoyar a sus aliados.";
  @override
  String get defender2CDescription =>
      "Esta carta tiene una resistencia dos veces mayor que la normal, pero es el doble de lenta que una carta normal.";
  @override
  String get defender4ADescription =>
      "Esta carta tiene una resistencia cuatro veces mayor que la normal, pero no es muy buena para atacar a sus enemigos.";
  @override
  String get defender4BDescription =>
      "Esta carta tiene una resistencia cuatro veces mayor que la normal, pero no es muy buena para apoyar a sus aliados.";
  @override
  String get defender4CDescription =>
      "Esta carta tiene una resistencia cuatro veces mayor que la normal, pero no destaca en otras áreas.";
  @override
  String get healer2ADescription =>
      "Esta carta cura a sus aliados dos veces más rápido que una carta normal, pero no es muy buena para atacar a sus enemigos.";
  @override
  String get healer2BDescription =>
      "Esta carta cura a sus aliados dos veces más rápido que una carta normal, pero es débil contra los ataques de sus enemigos.";
  @override
  String get healer2CDescription =>
      "Esta carta cura a sus aliados dos veces más rápido que una carta normal, pero es el doble de lenta que una carta normal.";
  @override
  String get healer4ADescription =>
      "Esta carta cura a sus aliados cuatro veces más rápido que una carta normal, pero no es muy buena para atacar a sus enemigos.";
  @override
  String get healer4BDescription =>
      "Esta carta cura a sus aliados cuatro veces más rápido que una carta normal, pero es muy débil contra los ataques de sus enemigos.";
  @override
  String get healer4CDescription =>
      "Esta carta cura a sus aliados cuatro veces más rápido que una carta normal, pero no destaca en otras áreas.";
  @override
  String get specialExpansionDescription =>
      "Esta carta aumenta en uno las opciones de ataque de la carta objetivo, ya sea aliada o no.";
  @override
  String get specialCompressionDescription =>
      "Esta carta disminuye en uno las opciones de ataque de la carta objetivo, ya sea aliada o no.";
  @override
  String get specialDecelerationDescription =>
      "Esta carta reduce la velocidad de sus objetivos a la mitad. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialAccelerationDescription =>
      "Esta carta aumenta la velocidad de sus objetivos al doble. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialAttackIncreaseDescription =>
      "Esta carta mejora a sus objetivos al duplicar su ataque. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialAttackDecreaseDescription =>
      "Esta carta debilita a sus objetivos al reducir a la mitad su ataque. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialResistanceIncreaseDescription =>
      "Esta carta mejora a sus objetivos al duplicar su resistencia. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialResistanceDecreaseDescription =>
      "Esta carta debilita a sus objetivos al reducir a la mitad su resistencia. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialSupportIncreaseDescription =>
      "Esta carta mejora a sus objetivos al duplicar su apoyo. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialSupportDecreaseDescription =>
      "Esta carta debilita a sus objetivos al reducir a la mitad su apoyo. No importa si el objetivo es aliado o enemigo.";
  @override
  String get specialCloningDescription =>
      "Esta carta de duración limitada permite clonar todas las propiedades y habilidades de una carta objetivo en el campo de juego.";
  @override
  String get specialCancellationDescription =>
      "Esta carta cancela el efecto especial de sus objetivos, ya sea aliada o no. Pero no puede ser cancelada a su vez.";
  @override
  String get specialRefrigerationDescription =>
      "Esta carta evita que sus objetivos sean modificados por su propietario, ya sea aliada o no.";
  @override
  String get specialAspiratorDescription =>
      "Esta carta elimina todas las cartas que se encuentran a una distancia de una casilla de ella después de un retraso proporcional a su nivel actual.";
  @override
  String get specialSubstractionDescription =>
      "Esta carta elimina todas las cartas que se encuentran en su fila y columna después de un retraso proporcional a su nivel actual.";
  @override
  String get specialDivisionDescription =>
      "Esta carta elimina todas las cartas que se encuentran en sus diagonales después de un retraso proporcional a su nivel actual.";
  @override
  String get specialDeflagrationDescription =>
      "Esta carta elimina todas las cartas en su fila, columna y diagonales después de un retraso proporcional a su nivel actual.";
  @override
  String get specialParalysisDescription =>
      "Esta carta de duración limitada evita que sus objetivos ataquen o se defiendan, ya sean aliados o no.";
  @override
  String get specialInvulnerabilityDescription =>
      "Esta carta de duración limitada hace que sus objetivos sean invulnerables durante un período proporcional a su nivel.";
  @override
  String get specialVortexDescription =>
      "Esta carta de duración limitada permite mover una carta objetivo en el campo de juego intercambiando su posición con ella.";

  /* JUEGO */

  @override
  String get gameAbandonmentButtonDescription =>
      "¡Tu oponente será declarado automáticamente como ganador! ¿Realmente quieres abandonar esta partida?";
  @override
  String get gameAbandonmentButtonAbandon => "Abandonar";
  @override
  String get gameAbandonmentButtonTitle => "Abandonar";

  @override
  String get gameBottomButtonDisplayResult => "Mostrar resultado";

  @override
  String get gameCardsSummaryPlay => "Jugar";
  @override
  String get gameCardsSummaryRemember => "¡Recuerda bien!";

  @override
  String get gameInitialTutorialPopupPlay => "Jugar";

  @override
  String get gamePassButtonPopupPass => "Saltar";
  @override
  String get gamePassButtonPopupDescription =>
      "Antes de continuar, asegúrate de conocer bien las reglas del juego. ¿Realmente quieres saltarte el tutorial?";
  @override
  String get gamePassButtonPopupTitle => "Saltar el tutorial";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "¡Felicidades por tu victoria! Has superado este nivel con éxito. ¡Puedes avanzar al siguiente nivel!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "¡No tienes suficientes cauris para jugar el siguiente nivel! ¡Mira un anuncio para obtener 1 cauri!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "¡Has completado el modo 'Solitario'!\n¡Jugadores de todo el mundo te esperan en el mundo de los juegos en línea!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "¡Disculpa por tu derrota! No te desanimes: ¡siempre puedes mejorar volviendo a jugar!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "Lamentablemente, no tienes suficientes cauris para volver a jugar. ¡Mira un anuncio para obtener 1 cauri!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "¡Disculpa por tu derrota! De todos modos, ya has pasado este nivel y puedes avanzar al siguiente nivel!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "¡No tienes suficientes cauris para jugar el siguiente nivel! ¡Mira un anuncio para obtener 1 cauri!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "¡Disculpa por tu derrota! De todos modos, ¡ya has completado todos los niveles de este modo de juego!";
  @override
  String get remoteDefeatDescription =>
      "¡Disculpa por tu derrota! No te desanimes: ¡siempre puedes mejorar jugando más partidas!";
  @override
  String get remoteVictoryDescription =>
      "¡Felicidades por tu victoria! ¡Todavía puedes mejorar tu nivel participando en más partidas en línea!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "Lamentablemente, no tienes suficientes cauris para volver a jugar. ¡Mira un anuncio para obtener 1 cauri!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "El otro jugador ya no está disponible para jugar una partida. ¡Pero aún tienes muchas otras opciones!";
  @override
  String get externalNeedinessDescription =>
      "El otro jugador ya no tiene suficientes cauris para jugar. ¡Pero puedes esperar o comenzar una nueva partida!";
  @override
  String get internalNeedinessTitle => "¡Cauris insuficientes!";
  @override
  String get replayImpossibleDescription =>
      "El otro jugador ya no está conectado. ¡Pero aún puedes jugar una nueva partida con otro jugador!";
  @override
  String get invitationWithdrawalDescription =>
      "El otro jugador ha retirado su invitación para volver a jugar. ¡Pero aún puedes jugar una nueva partida!";
  @override
  String get invitationRejectionDescription =>
      "Lamentablemente, tu invitación ha sido rechazada. ¡Pero aún puedes jugar una nueva partida!";
  @override
  String get invitationAcceptationDescription =>
      "Ambos están listos para volver a jugar. ¡Un poco de paciencia! ¡El juego se reanudará en breve!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "¡No tienes suficientes cauris para aceptar una invitación! ¡Mira un anuncio para obtener 1 cauri!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "El otro jugador quiere jugar una nueva partida contigo. ¿Quieres aceptar o rechazar su invitación?";
  @override
  String get internalInvitationDescription =>
      "El otro jugador ha recibido una notificación de tu invitación para volver a jugar. ¡Puede aceptarla o rechazarla!";
  @override
  String get gamePopupNewGame => "Nuevo\njuego";
  @override
  String get gamePopupNextLevel => "Siguiente\nnivel";
  @override
  String get gamePopupReplay => "Repetir";
  @override
  String get globalExit => "Salir";
  @override
  String get globalAccept => "Aceptar";
  @override
  String get globalReject => "Rechazar";
  @override
  String get globalCancel => "Cancelar";
  @override
  String get normalDefeatTitle => "¡Has perdido!";
  @override
  String get defeatByAbandonment => "Derrota por abandono!";
  @override
  String get normalVictoryTitle => "¡Has ganado!";
  @override
  String get victoryByAbandonment => "Victoria por abandono!";
  @override
  String get externalNeedinessTitle => "¡Ups!";
  @override
  String get internalNeedinessDescription =>
      "El otro jugador quiere jugar una nueva partida contigo, pero no tienes suficientes cauris para jugar!";
  @override
  String get replayImpossibleTitle => "¡Repetición imposible!";
  @override
  String get invitationWithdrawalTitle => "¡Invitación retirada!";
  @override
  String get invitationRejectionTitle => "¡Invitación rechazada!";
  @override
  String get invitationAcceptationTitle => "¡Cargando el juego!";
  @override
  String get externalInvitationTitle => "¿Quieres jugar de nuevo?";
  @override
  String get internalInvitationTitle => "¡Un poco de paciencia!";
  @override
  String get gameProfilePosterClose => "Cerrar";
  @override
  String get gameProfilePosterDeck => "Mazo";
  @override
  String get gameProfilePosterCards => "Cartas";
  @override
  String get gameProfilePosterCrowns => "Coronas";

  @override
  List<String> get names => [
    "Alex",
    "Sonia",
    "Basile",
    "Yoann",
    "Isaac",
    "Roberto",
    "Tanguy",
    "Jessé",
    "Alice",
    "Christian",
    "Fabienne",
    "Mimi",
    "Maurice",
    "Lucie",
    "Josiane",
    "Vianney",
    "Anicette",
    "Adeline",
    "Bénédicte",
    "Rosa",
    "Déborah",
    "Ange",
    "Clémence",
    "Aude",
    "Mireille",
    "Cécile",
    "Laurence",
    "Marius",
    "Nadège",
    "Sylvie",
    "Clarisse",
    "Claude",
    "Clotilde",
    "André",
    "Christine",
    "Léopold",
    "Geneviève",
    "Esther",
    "Flore",
    "Angèle",
    "Jennifer",
    "Hugues",
    "Huguette",
    "Olivier",
    "Judith",
    "Martine",
    "Rachel",
    "Antoine",
    "Alfred",
    "Marthe",
    "Bob",
  ];

  @override
  String gameTileNameLevel(int level) => "Nivel $level";
  @override
  String get gameTopBarTutorialText => "Tutorial";

  @override
  String get gametutorialCongratulationsPopupPlay => "Jugar";
  @override
  String get gametutorialCongratulationsPopupTitle => "¡Felicidades!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "¡Has completado esta lección con éxito! ¡Pero siempre puedes volver a empezar si aún hay áreas oscuras!";

  @override
  String get gameTutorialPopupTitle => "Ayuda";

  @override
  String get gameTutorialProgressPopupNextLesson => "Siguiente Lección";
  @override
  String get gameTutorialProgressPopupTitle => "¡Felicidades!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Cowries!";

  @override
  String referralNotificationBody(String name) =>
      "¡Felicidades! Recibiste 50 cowries gracias al registro de $name.";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "No te hemos visto en varios días. ¡Ven a ejercitar tu cerebro mientras te diviertes!";
  @override
  String get notificationMissTitle => "¡Te Extrañamos!";
  @override
  String get notificationGiftBody =>
      "¡Cada hora recibes cowries gratis! ¡Ven a reclamar tu regalo!";
  @override
  String get notificationGiftTitle => "¡No Te Pierdas Tu Regalo!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Espera a que el rey cambie de color para ganar el juego.";
  @override
  String get invalidDeckTitle => "Mazo Inválido!";
  @override
  String get invalidDeckDescription =>
      "Tu mazo actual no es válido. ¡Por favor, arréglalo o selecciona otro antes de empezar un nuevo juego!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "No pudimos conectarnos a tu cuenta de juego. ¡Por favor, verifica tu conexión a internet e inténtalo de nuevo!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Error de Autenticación!";

  @override
  String get globalRetry => "Reintentar";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Autenticación Requerida!";
  @override
  String get authenticationPopupLoadingAuthentication => "Autenticando!";

  @override
  String authenticationPopupDescription(String account) =>
      "Te conectaremos a tu cuenta de $account para guardar tu progreso en el juego!";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Juegos";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Mazo $index";

  @override
  String get cardOptionButtonDescription =>
      "Puedes tener hasta 3 mazos. Consulta y selecciona tu mazo de juego aquí.";

  @override
  String get globalValidate => "Validar";

  @override
  String get blockedAccountContactSakiHub => "Contactar a Saki Hub";

  @override
  String get blockedAccountDescription =>
      "El bloqueo de la cuenta es resultado de actividad ilegal o sospechosa. Si este bloqueo es un error, ¡por favor contáctanos!";
  @override
  String get blockedAccountTitle => "¡Tu Cuenta Ha Sido Bloqueada!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Los cowries aumentan tu libertad de juego, pero debes estar conectado para usarlos!";

  @override
  String get progressOptionButtonNotAuthenticatedTitle => "No Tienes Cowries!";
  @override
  String get progressOptionButtonShowcase =>
      "El cowrie, la moneda del juego, es esencial para comprar cartas y jugar. Gestiona tus cowries aquí.";

  @override
  String get globalAd => "ANUNCIO";

  @override
  String get globalConnect => "Conectar";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Atacantes";
  @override
  String get attackerFamilyShortDescription =>
      "Cartas rojas: Fuertes en el ataque";
  @override
  String get attackerFamilyLongDescription =>
      "Estas cartas infligen el mayor daño a sus enemigos. Sin embargo, no son excelentes en otras áreas!";

  @override
  String get defenderFamilyName => "Defensores";
  @override
  String get defenderFamilyShortDescription =>
      "Cartas grises: Fuertes en la defensa";
  @override
  String get defenderFamilyLongDescription =>
      "Estas cartas tienen los valores de defensa más altos. Sin embargo, no son excelentes en otras áreas!";

  @override
  String get healerFamilyName => "Sanadores";
  @override
  String get healerFamilyShortDescription =>
      "Cartas verdes: Fuertes en la curación";
  @override
  String get healerFamilyLongDescription =>
      "Estas cartas sanan mejor a sus aliados. Sin embargo, no son excelentes en otras áreas!";

  @override
  String get lordFamilyName => "Señores";
  @override
  String get lordFamilyShortDescription =>
      "Señores: Deben protegerse a toda costa";
  @override
  String get lordFamilyLongDescription =>
      "Estas son las cartas que deben protegerse a toda costa en el juego: ¡pierdes automáticamente si el color de tu señor cambia!";

  @override
  String get normalFamilyName => "Normales";
  @override
  String get normalFamilyShortDescription =>
      "Cartas marrones: Habilidades equilibradas";
  @override
  String get normalFamilyLongDescription =>
      "Los Normales son los más equilibrados del juego. Son muy versátiles y ofrecen una verdadera ventaja en el campo!";

  @override
  String get specialFamilyName => "Especiales";
  @override
  String get specialFamilyShortDescription =>
      "Cartas amarillas: Efectos especiales en otras cartas";
  @override
  String get specialFamilyLongDescription =>
      "Estas cartas tienen efectos en otras cartas. ¡Sus efectos dependen principalmente de su naturaleza!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Lección 1/3: Fundamentos del Juego";
  @override
  String get globalLesson => "Lección";
  @override
  String get basicsLessonSuffix => "Fundamentos del Juego";
  @override
  String get basicsLessonWinningMessage =>
      "¡Felicitaciones por tu victoria! ¡Avanza rápidamente a la siguiente lección para dominar el papel de las cartas del juego!";

  @override
  String get normalLessonTitle => "Lección 2/3: Papel de las Cartas";
  @override
  String get normalLessonSuffix => "Papel de las Cartas";
  @override
  String get specialLessonSuffix => "Cartas Especiales";
  @override
  String get normalLessonDescription =>
      "Las cartas rojas son buenas para atacar, las cartas verdes brindan apoyo, las cartas grises ofrecen resistencia y las cartas marrones son equilibradas.";
  @override
  String get normalLessonWinningMessage =>
      "¡Felicitaciones por tu victoria! ¡Continúa con la siguiente lección para comprender el papel de las cartas amarillas!";

  @override
  String get specialLessonTitle => "Lección 3/3: Cartas Especiales";
  @override
  String get specialLessonDescription =>
      "Las cartas amarillas tienen efectos especiales en otras cartas. ¡El efecto de una carta especial depende únicamente de su naturaleza!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Impresionante";
  @override
  String get congratulationsMessage => "Felicitaciones";
  @override
  String get excellentMessage => "Excelente";
  @override
  String get goodMessage => "Bueno";
  @override
  String get greatMessage => "Genial";
  @override
  String get magnificentMessage => "Magnífico";
  @override
  String get masterfulMessage => "Magistral";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "Coloca una de tus cartas en el tablero para aumentar tus aliados.";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Conéctate a la carta gris para convertirla en un aliado del reino.";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Espera a que la carta gris cambie de color antes de poder usarla.";
  @override
  String get basicsCutPathInstruction =>
      "Elimina la conexión entre las dos cartas según se indica.";
  @override
  String get basicsConnectKingInstruction =>
      "Conéctate al rey del oponente para comenzar a atacarlo.";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Necesitas contraatacar. Coloca un atacante en el tablero de juego.";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "El oponente jugó una carta ciudadano. Ataca antes de que te ataque.";
  @override
  String get normalPlaceHealerInstruction =>
      "Tu rey está bajo ataque y necesita ser curado. Coloca un sanador en el campo de juego.";
  @override
  String get normalConnectHealerInstruction =>
      "Cura a tu rey rápidamente para evitar que cambie de color.";
  @override
  String get normalPlaceAttackerInstruction =>
      "Necesitas contraatacar. Coloca un atacante en el tablero de juego.";
  @override
  String get normalConnectAttackerInstruction =>
      "Ataca a la carta que te está atacando para proteger al rey.";
  @override
  String get normalConquerAttackerInstruction =>
      "Espera a que la carta de la izquierda cambie de color antes de poder usarla.";
  @override
  String get normalPlaceDefenderInstruction =>
      "Tu ciudadano ha sido derrotado. Coloca un defensor para proteger a tu rey.";
  @override
  String get normalConnectDefenderInstruction =>
      "Defiende a tu rey atacando a la carta que amenaza a tu rey.";
  @override
  String get normalConnectKingInstruction =>
      "Estás siendo atacado, pero mantén el enfoque en el rey del oponente.";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Necesitas contraatacar. Coloca un atacante en el tablero de juego.";
  @override
  String get specialPlaceCompressionInstruction =>
      "El oponente ha contraatacado. Usa COMPRESIÓN para defenderte.";
  @override
  String get specialConnectCompressionInstruction =>
      "La COMPRESIÓN se utiliza para eliminar una conexión de sus objetivos. Úsala.";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "El oponente persiste. Usa REFRIGERACIÓN para congelar al enemigo.";
  @override
  String get specialConnectRefrigerationInstruction =>
      "La REFRIGERACIÓN evita que sus objetivos se alteren. Úsala.";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "La carta congelada está a tu merced. Atácala para convertirla en un aliado.";
  @override
  String get specialPlaceExpansionInstruction =>
      "El oponente persiste. Usa EXPANSIÓN para defenderte.";
  @override
  String get specialConnectExpansionInstruction =>
      "La EXPANSIÓN aumenta las conexiones de tus objetivos. Úsala.";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Gracias a EXPANSIÓN, puedes atacar a 2 cartas objetivo. ¡Vamos!";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Espera a que la carta de la derecha cambie de color antes de poder usarla.";
  @override
  String get specialConnectKingInstruction =>
      "Termina este tutorial con un golpe maestro atacando al rey del oponente.";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get basicsConnectCenterTileDescription =>
      "Para conectarte con la carta gris, arrastra desde la carta que acabas de colocar hasta la carta gris.";
  @override
  String get basicsConquerCenterTileDescription =>
      "Para cambiar el color de la carta gris, necesitas una conexión con ella y reducir sus puntos a 0.";
  @override
  String get basicsCutPathDescription =>
      "Para eliminar la conexión entre las dos cartas, arrastra para dibujar un segmento que corte la conexión.";
  @override
  String get basicsConnectKingDescription =>
      "Para conectarte con el rey del oponente, arrastra desde la carta que acabas de colocar hasta el rey.";
  @override
  String get kingConquestDescription =>
      "Para cambiar el color de la carta del rey, necesitas una conexión con ella y reducir sus puntos a 0.";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "Para conectarte con la carta objetivo, arrastra desde la carta original hasta la carta a la que apuntas.";
  @override
  String get normalPlaceHealerDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get normalConnectHealerDescription =>
      "Para curar a tu rey, arrastra desde la carta original hasta la carta a la que apuntas.";
  @override
  String get normalPlaceAttackerDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get normalConnectAttackerDescription =>
      "Para proteger a tu rey, ataca a la carta que te está atacando.";
  @override
  String get normalConquerAttackerDescription =>
      "Para cambiar el color de la carta objetivo, necesitas una conexión con ella y reducir sus puntos a 0.";
  @override
  String get normalPlaceDefenderDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get normalConnectDefenderDescription =>
      "Para defender a tu rey, ataca a la carta que amenaza a tu rey.";
  @override
  String get normalConnectKingDescription =>
      "Para proteger a tu rey, ataca al rey del oponente.";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get specialPlaceCompressionDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get specialConnectCompressionDescription =>
      "Para eliminar una conexión de tus objetivos, arrastra desde la carta original hasta la carta a la que apuntas.";
  @override
  String get specialPlaceRefrigerationDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get specialConnectRefrigerationDescription =>
      "Para evitar que tus objetivos cambien, arrastra desde la carta original hasta la carta a la que apuntas.";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "Para convertir la carta congelada en un aliado, arrástrala desde la carta original hasta la carta a la que apuntas.";
  @override
  String get specialPlaceExpansionDescription =>
      "Para colocar una carta en el tablero de juego, arrástrala desde la carta a la posición deseada.";
  @override
  String get specialConnectExpansionDescription =>
      "Para aumentar las conexiones de tus objetivos, arrastra desde la carta original hasta la carta a la que apuntas.";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "Gracias a la EXPANSIÓN, puedes atacar a 2 cartas objetivo. ¡Vamos!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "Espera a que la carta de la derecha cambie de color antes de poder usarla.";
  @override
  String get specialConnectKingDescription =>
      "Termina este tutorial con un golpe maestro atacando al rey del oponente.";

  /* SKILLS */

  @override
  String get attackSkillNull => "Nulo";
  @override
  String get attackSkillVeryBad => "Muy Malo";
  @override
  String get attackSkillBad => "Malo";
  @override
  String get attackSkillNormal => "Normal";
  @override
  String get attackSkillGood => "Bueno";
  @override
  String get attackSkillVeryGood => "Muy Bueno";

  @override
  String get supportSkillNull => "Nulo";
  @override
  String get supportSkillVeryBad => "Muy Malo";
  @override
  String get supportSkillBad => "Malo";
  @override
  String get supportSkillNormal => "Normal";
  @override
  String get supportSkillGood => "Bueno";
  @override
  String get supportSkillVeryGood => "Muy Bueno";

  @override
  String get resistanceSkillNull => "Nulo";
  @override
  String get resistanceSkillVeryBad => "Muy Malo";
  @override
  String get resistanceSkillBad => "Malo";
  @override
  String get resistanceSkillNormal => "Normal";
  @override
  String get resistanceSkillGood => "Bueno";
  @override
  String get resistanceSkillVeryGood => "Muy Bueno";

  @override
  String get lifeSkillNull => "Nulo";
  @override
  String get lifeSkillHalf => "Mitad";
  @override
  String get lifeSkillNormal => "Normal";

  @override
  String get speedSkillNull => "Nulo";
  @override
  String get speedSkillHalf => "Mitad";
  @override
  String get speedSkillNormal => "Normal";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "¡Cerrar esta parte te costará exactamente $cowries cauríes! ¿Realmente deseas cerrar el juego?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "¡Cerrar esta parte te costará exactamente $cowries cauríes! ¿Realmente deseas cerrar el juego?";
  @override
  String get adventureSimpleCloseDescription =>
      "¡Cerrar el juego actual resultará en la pérdida de tu progreso! ¿Realmente deseas cerrar el juego actual?";
  @override
  String get remoteSimpleCloseDescription =>
      "¡Cerrar esta parte resultará en la pérdida de su progreso actual! ¿Realmente deseas cerrar esta parte?";
  @override
  String get closeClose => "Cerrar";
  @override
  String get closeTitle => "Cerrar";

  @override
  String get watchAdButtonRefreshAd => "Actualizar anuncio";
  @override
  String get cardOptionButtonPopupSelectDeck => "Seleccionar esta baraja";

  @override
  String get lessonChangeTitle => "Cambio de lección";
  @override
  String get lessonChangeDescription =>
      "¡Por favor, domine las enseñanzas de esta lección antes de pasar a otra! ¿Realmente desea cambiar de lección?";
  @override
  String get lessonChangeAction => "Cambiar";
  @override
  String get restoreDefaultLanguage => "Restablecer el idioma por defecto";

  //

  @override
  String get loadingDescription =>
      "Estamos cargando los datos del juego. ¡Por favor, espere un momento!";
  @override
  String get homeUpdateSimpleDescription =>
      "Una nueva versión del juego está disponible. ¡Instálala rápidamente para disfrutar de las últimas características!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "¡Ahora puedes ingresar al universo del juego y explorar todas sus complejidades!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "¡Soy la inteligencia artificial del nivel $level del juego! ¡Haré todo lo posible para brindarte un gran juego!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "Soy la inteligencia artificial del tutorial del juego. ¡Solo sigue las instrucciones para ganar!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "¡Transacción cancelada!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "No pudimos validar tu compra. ¡Por favor, verifica tu método de pago y tu conexión a internet!";

  @override
  String get drawTitle => "¡Empate!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "¡Terminaste en empate! De todos modos, ¡ya has completado todos los niveles de este modo de juego!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "¡Terminaste en empate! De todos modos, ¡ya has pasado este nivel y puedes ir al siguiente nivel!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "¡Terminaste en empate! ¡Todavía puedes ganar volviendo a jugar contra la IA!";
  @override
  String get remoteDrawDescription =>
      "¡No has ganado ni perdido! ¿Por qué no empezar otra partida con el otro jugador para desempatar?";
  @override
  String get newPlayer => "Nuevo jugador";

  @override
  String get premiumButtonRemoveAds => "Eliminar anuncios";

  @override
  String get localNetworkWaitingForHost => "Esperando al anfitrión…";

  @override
  String get localNetworkHostLeftDescription =>
      "El anfitrión ha salido de la partida: la mesa ha terminado. Puedes empezar otra desde el menú.";

  @override
  String get replayVoteChooseOption => "Elige un modo para la revancha";

  @override
  String replayVoteCountdown(int seconds) =>
      "Empieza en ${seconds}s con los jugadores listos";

  @override
  String get replayVoteStartingSoon =>
      "La partida comenzará con los jugadores que aceptaron";

  @override
  String get replayVoteWaitingForPlayers => "Esperando a los demás jugadores";
}
