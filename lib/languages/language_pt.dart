import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguagePt extends GamicoLanguages {
  @override
  String get globalMax => "MÁX";
  @override
  String get globalRefresh => "Atualizar";
  @override
  String get globalClose => "Fechar";
  @override
  String get globalOK => "OK";

  /* FRIEND */

  @override
  String get friendPageTitle => "Procurar amigos";

  @override
  String get friendPageSearchHint => "Buscar por nome...";

  @override
  String get friendPagePendingInvitations => "Convites pendentes";

  @override
  String get friendPageGameInvitation => "Convite para jogo";

  @override
  String friendPageInvitationFrom(String name) => "De: $name";

  @override
  String get friendPageInvitationSent => "Convite enviado!";

  @override
  String get friendPageFailedToSendInvitation => "Falha ao enviar convite";

  @override
  String get friendPageUnknown => "Desconhecido";
  @override
  String get notificationInvitationBody => "Você recebeu um convite para jogar!";
  @override
  String notificationInvitationFrom(String name) => "$name convida você para jogar!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Ajuda";
  @override
  String get adventureHelpDescription =>
      "Você pode selecionar um nível clicando nele. Mas se você ainda não sabe jogar bem, siga o tutorial!";
  @override
  String get adventureClose => "Fechar";
  @override
  String get adventureFollow => "Seguir";

  @override
  String adventureChapterChapter(int chapter) => "Capítulo $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Família: $family";
  @override
  String get collectionCardPopupUpgrade => "Melhorar";
  @override
  String get collectionCardPopupRemove => "Remover";
  @override
  String get collectionCardPopupUse => "Usar";
  @override
  String get collectionCardPopupAcquire => "Adquirir";

  @override
  String get collectionCardSkillsAttack => "Ataque";
  @override
  String get collectionCardSkillsSupport => "Suporte";
  @override
  String get collectionCardSkillsResistance => "Resistência";
  @override
  String get collectionCardSkillsTheoreticalLife => "Vida Teórica";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "Velocidade Teórica";
  @override
  String get collectionCardSkillsPower => "Poder";
  @override
  String get collectionCardSkillsConcreteLife => "Vida Concreta";
  @override
  String get collectionCardSkillsConcreteSpeed => "Velocidade Concreta";
  @override
  String get collectionCardSkillsConnections => "Conexões";

  @override
  String collectionCardSquareLevel(int level) => "Nível $level";

  @override
  String get collectionCardBlocked => "Bloqueado";
  @override
  String collectionCardLevel(int level) => "Nível $level";

  @override
  String get collectionContentDeck => "Baralhos";
  @override
  String get collectionContentUnlockedCards => "Cartas Desbloqueadas";
  @override
  String get collectionContentRemainingCards => "Cartas restantes";

  /* HOME */

  @override
  String get homeLanguagesTitle => "Línguas";

  @override
  String get homeMultiplayerButtonShowcase =>
      "Este botão permite que você jogue partidas com outros jogadores online.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "Este botão permite que você jogue partidas com a inteligência artificial do jogo.";
  @override
  String get homeNotificationsTitle => "Notificações";
  @override
  String get homeNotificationsDescription =>
      "Para melhorar sua experiência de jogo, você deve permitir notificações! Deseja permitir notificações?";
  @override
  String get homeNotificationsAllow => "Permitir";
  @override
  String get homeNotificationsReminderTitle => "Ativar notificações";
  @override
  String get homeNotificationsReminderDescription =>
      "As notificações são importantes para uma melhor experiência de jogo. Deseja ativá-las agora?";
  @override
  String get homeUpdateTitle => "Atualização disponível!";
  @override
  String get homeUpdateForceDescription =>
      "Vários erros e problemas foram corrigidos na nova versão. Instale-a rapidamente para aproveitar essas correções!";
  @override
  String get homeUpdateInstall => "Instalar";

  @override
  String get homeAbout => "Sobre";
  @override
  String homeAboutPopupShareText(String link) =>
      "Descobri um jogo de estratégia muito interessante! Baixe-o gratuitamente em $link!";
  @override
  String get homeAboutPopupImplementation => "Implementação";
  @override
  String get homeAboutPopupMusic => "Música";
  @override
  String get homeAboutPopupVersion => "Versão";
  @override
  String get homeAboutPopupRateGame => "Avaliar o jogo";
  @override
  String get homeAboutPopupVisitWebstie => "Visitar Saki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "Ver meus aplicativos";

  @override
  String get homeCardPresentationShowcase =>
      "Use este menu para comprar novos cartões e melhorar os que você já possui.";
  @override
  String get homeCardPresentationShow => "Ver todos os cartões";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "Erro de Conexão!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Por favor, verifique sua conexão com a internet. Esta seção será atualizada automaticamente quando você estiver conectado!";
  @override
  String get homeGratificationPopupLoadingTitle => "Carregando Recompensas!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "As recompensas estarão disponíveis em apenas alguns segundos. Por favor, aguarde!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Carimbo de Data/Hora Incorreto!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle =>
      "Problema de Conexão!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "Parece que você não está conectado à internet. Por favor, verifique a qualidade da sua conexão à internet e tente novamente!";
  @override
  String get homeMultiplayerButtonText => "Multi";

  @override
  String get homeProfilePopupBestTacticians => "Melhores Táticos";
  @override
  String get homeProfilePopupDescription =>
      "Os jogadores são classificados com base em dois critérios: o número de vitórias online e o número máximo de cowries!";
  @override
  String get homeProfilePopupBestCollectors => "Melhores Colecionadores";
  @override
  String get homeProfilePopupCheckAchievements => "Ver Minhas Conquistas";

  @override
  String get homeSingleplayerButtonText => "Solo";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "As ofertas especiais ativam a cada 3 dias e são válidas por apenas 24 horas. Não perca a próxima!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "As ofertas especiais ativam a cada 3 dias e são válidas por apenas 24 horas. Então, o que está esperando para aproveitar?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Os dados relacionados à oferta especial estarão disponíveis em breve. Por favor, aguarde um momento!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "Não conseguimos validar sua compra. Por favor, verifique seu método de pagamento e sua conexão com a internet!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle!";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "Carregando Oferta!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Transação Cancelada!";
  @override
  String get homeSpecialOfferPopupClose => "Fechar";
  @override
  String get homeSpecialOfferPopupTimestampTitle =>
      "Carimbo de Data/Hora Incorreto!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Os dados relacionados à oferta especial estarão disponíveis em breve. Por favor, aguarde um momento!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Carregando Oferta!";
  @override
  String get homeSpecialOfferPopupProblemClose => "Fechar";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Erro de Conexão!";

  @override
  String get premiumPopupTitle => "Modo Premium";
  @override
  String get premiumPopupDescription => "Desbloqueie a versão completa para remover todos os anúncios!";
  @override
  String get premiumPlayer => "Jogador Premium";
  @override
  String get nonPremiumPlayer => "Jogador não premium";

  @override
  String get homeHelpBasicsA =>
      "O reino dos Azuis enfrenta o reino dos Laranjas.";
  @override
  String get homeHelpBasicsB =>
      "Pode-se ganhar mudando a cor do lorde inimigo.";
  @override
  String get homeHelpBasicsC =>
      "Pode-se ganhar tendo a maioria dos pontos de vida dentro do tempo alocado.";

  @override
  String get homeHelpConnections1A =>
      "Você pode tocar e arrastar para conectar dois cartões.";
  @override
  String get homeHelpConnections1B =>
      "Você pode tocar e tocar para conectar dois cartões.";
  @override
  String get homeHelpConnections1C =>
      "Você pode cortar uma conexão deslizando o dedo.";

  @override
  String get homeHelpConnections2A =>
      "Uma conexão pode às vezes dificultar a capacidade de jogar.";
  @override
  String get homeHelpConnections2B =>
      "Não é possível pular por cima de um cartão para se conectar a outro.";
  @override
  String get homeHelpConnections2C =>
      "Um cartão em MAX retorna todas as bolas que recebe.";

  @override
  String get homeHelpCards1A => "Os cartões vermelhos são bons para atacar.";
  @override
  String get homeHelpCards1B => "Os cartões cinzas são bons para resistir.";
  @override
  String get homeHelpCards1C => "Os cartões verdes são bons para apoiar.";

  @override
  String get homeHelpCards2A =>
      "Os cartões marrons têm habilidades equilibradas.";
  @override
  String get homeHelpCards2B =>
      "Os cartões amarelos têm efeitos especiais em outros cartões.";
  @override
  String get homeHelpCards2C =>
      "Os cartões brancos são os que devem ser protegidos a todo custo.";

  @override
  String get homeHelpRestrictionsA =>
      "Toda conexão deve ser útil. Aqui, é inútil e, portanto, impossível.";
  @override
  String get homeHelpRestrictionsB =>
      "Um cartão de destruição não pode atacar um lorde.";
  @override
  String get homeHelpRestrictionsC =>
      "Não é possível clonar ou mover um lorde.";

  /* LOADING */

  @override
  String get loadingTitle => "Por favor, aguarde!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Problema de conexão!";
  @override
  String get remoteConnexionProblemDescription =>
      "Desculpe! Sua conexão com a Internet foi desconectada. Você foi declarado o perdedor do jogo!";
  @override
  String get remoteInvitationTitle => "Venha e jogue!";
  @override
  String get remoteInvitationDescription => "Seu jogo online começou!";
  @override
  String get remoteMultiplayer => "Multijogador";

  @override
  String get remoteFailurePosterTitle => "Ocorreu um erro!";
  @override
  String get remoteFailurePosterDescription =>
      "Ocorreu um erro durante a pesquisa. Verifique sua conexão com a Internet e tente novamente!";

  @override
  String get remoteImpossibleGamePosterTitle => "Cauris Insuficientes!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "Você precisa ter pelo menos $cowries cauris para jogar online!";

  @override
  String get remoteNewGamePosterTitle => "Um Novo Jogo?";
  @override
  String get remoteNewGamePosterDescription =>
      "Você ainda pode jogar com jogadores de todo o mundo para melhorar seu nível!";

  @override
  String get remoteSearchPosterTitle => "Busca de Jogadores";
  @override
  String get remoteSearchPosterDescription =>
      "Estamos procurando jogadores em todo o mundo para jogar com você!";

  @override
  String get homeTranslationPopupDescription =>
      "Esta seção permite que você escolha o idioma principal do jogo. Clique em um idioma para ativá-lo automaticamente!";

  /* TÍTULOS DOS CARTÕES */

  @override
  String get lordLazyKingName => "Rei Preguiçoso";
  @override
  String get lordLazyQueenName => "Rainha Frágil";
  @override
  String get lordLazyPrinceName => "Príncipe Solitário";
  @override
  String get lordLazyPrincessName => "Princesa Introvertida";
  @override
  String get lordCourageousKingName => "Rei Pragmático";
  @override
  String get lordCourageousQueenName => "Rainha Destemida";
  @override
  String get lordCourageousPrinceName => "Príncipe Resistente";
  @override
  String get lordCourageousPrincessName => "Princesa Devotada";
  @override
  String get normalOrdinaryCitizenName => "Cidadão Comum";
  @override
  String get normalAttackerDefenderName => "Guarda Militar";
  @override
  String get normalAttackerHealerName => "Médico Militar";
  @override
  String get normalDefenderHealerName => "Guarda Médico";
  @override
  String get attacker2AName => "Gripe";
  @override
  String get attacker2BName => "Sol";
  @override
  String get attacker2CName => "Centelha";
  @override
  String get attacker4AName => "Redemoinho";
  @override
  String get attacker4BName => "Mosquito";
  @override
  String get attacker4CName => "Ciclone";
  @override
  String get defender2AName => "Pedra";
  @override
  String get defender2BName => "Seixo";
  @override
  String get defender2CName => "Muralha";
  @override
  String get defender4AName => "Raio";
  @override
  String get defender4BName => "Varanda";
  @override
  String get defender4CName => "Janela";
  @override
  String get healer2AName => "Grama";
  @override
  String get healer2BName => "Flor";
  @override
  String get healer2CName => "Folha";
  @override
  String get healer4AName => "Arbusto";
  @override
  String get healer4BName => "Curativo";
  @override
  String get healer4CName => "Árvore";
  @override
  String get specialExpansionName => "Expansão";
  @override
  String get specialCompressionName => "Compressão";
  @override
  String get specialDecelerationName => "Desaceleração";
  @override
  String get specialAccelerationName => "Aceleração";
  @override
  String get specialAttackIncreaseName => "Bravura";
  @override
  String get specialAttackDecreaseName => "Covardia";
  @override
  String get specialResistanceIncreaseName => "Reforço";
  @override
  String get specialResistanceDecreaseName => "Enfraquecimento";
  @override
  String get specialSupportIncreaseName => "Altruísmo";
  @override
  String get specialSupportDecreaseName => "Individualismo";
  @override
  String get specialCloningName => "Clonagem";
  @override
  String get specialCancellationName => "Cancelamento";
  @override
  String get specialRefrigerationName => "Refrigeração";
  @override
  String get specialAspiratorName => "Abismo";
  @override
  String get specialSubstractionName => "Subtração";
  @override
  String get specialDivisionName => "Divisão";
  @override
  String get specialDeflagrationName => "Deflagração";
  @override
  String get specialParalysisName => "Paralisia";
  @override
  String get specialInvulnerabilityName => "Invulnerabilidade";
  @override
  String get specialVortexName => "Vórtice";

  /* DESCRIÇÕES DAS CARTAS */

  @override
  String get lordLazyKingDescription =>
      "Este é o único senhor que não pode atacar nem se defender. No entanto, ele é um rei equilibrado que não possui nenhum ponto fraco específico!";
  @override
  String get lordLazyQueenDescription =>
      "Esta é uma dama muito habilidosa em atacar e apoiar seus súditos, apesar de sua idade avançada. No entanto, sua resistência deixa a desejar!";
  @override
  String get lordLazyPrinceDescription =>
      "Este é um jovem muito habilidoso em atacar e resistir a ataques. No entanto, ele não sabe como apoiar seus súditos!";
  @override
  String get lordLazyPrincessDescription =>
      "Esta é uma jovem mulher muito habilidosa em resistir a ataques e apoiar seus súditos. No entanto, ela não é forte no ataque!";
  @override
  String get lordCourageousKingDescription =>
      "Este é um rei equilibrado que não possui nenhum ponto fraco específico. No entanto, ele tem metade dos pontos de vida do que é normal!";
  @override
  String get lordCourageousQueenDescription =>
      "Esta é uma dama extremamente habilidosa em atacar, apesar de sua idade avançada. Mas ela não se destaca em outras áreas!";
  @override
  String get lordCourageousPrinceDescription =>
      "Este é um jovem extremamente habilidoso em resistir a ataques. Mas este príncipe não se destaca em outras áreas!";
  @override
  String get lordCourageousPrincessDescription =>
      "Esta é uma jovem mulher extremamente habilidosa em apoiar seus súditos. Mas esta princesa não se destaca em outras áreas!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "Este cartão é o mais equilibrado do jogo. Ele não possui pontos fortes ou fracos específicos, mas ainda é um aliado confiável!";
  @override
  String get normalAttackerDefenderDescription =>
      "Como o nome sugere, este é um jovem habilidoso em atacar seus inimigos enquanto resiste aos ataques deles!";
  @override
  String get normalAttackerHealerDescription =>
      "Como o nome sugere, este é um jovem habilidoso em atacar seus inimigos enquanto apoia seus aliados!";
  @override
  String get normalDefenderHealerDescription =>
      "Como o nome sugere, este é um jovem habilidoso em apoiar seus aliados enquanto resiste aos ataques de seus inimigos!";
  @override
  String get attacker2ADescription =>
      "Este cartão inflige o dobro de dano aos seus inimigos em comparação com um cartão normal, mas não é muito bom em apoiar seus aliados!";
  @override
  String get attacker2BDescription =>
      "Este cartão inflige o dobro de dano aos seus inimigos em comparação com um cartão normal, mas tem resistência baixa contra os ataques de seus inimigos!";
  @override
  String get attacker2CDescription =>
      "Este cartão inflige o dobro de dano aos seus inimigos em comparação com um cartão normal, mas é duas vezes mais lento do que um cartão normal!";
  @override
  String get attacker4ADescription =>
      "Este cartão inflige quatro vezes mais dano aos seus inimigos em comparação com um cartão normal, mas não é bom em apoiar seus aliados!";
  @override
  String get attacker4BDescription =>
      "Este cartão inflige quatro vezes mais dano aos seus inimigos em comparação com um cartão normal, mas tem resistência muito baixa contra os ataques de seus inimigos!";
  @override
  String get attacker4CDescription =>
      "Este cartão inflige quatro vezes mais dano aos seus inimigos em comparação com um cartão normal, mas não se destaca em outras áreas!";
  @override
  String get defender2ADescription =>
      "Este cartão possui resistência duas vezes maior do que a normal, mas não é muito bom em atacar seus inimigos!";
  @override
  String get defender2BDescription =>
      "Este cartão possui resistência duas vezes maior do que a normal, mas não é muito bom em apoiar seus aliados!";
  @override
  String get defender2CDescription =>
      "Este cartão possui resistência duas vezes maior do que a normal, mas é duas vezes mais lento do que um cartão normal!";
  @override
  String get defender4ADescription =>
      "Este cartão possui resistência quatro vezes maior do que a normal, mas não é bom em atacar seus inimigos!";
  @override
  String get defender4BDescription =>
      "Este cartão possui resistência quatro vezes maior do que a normal, mas não é bom em apoiar seus aliados!";
  @override
  String get defender4CDescription =>
      "Este cartão possui resistência quatro vezes maior do que a normal, mas não se destaca em outras áreas!";
  @override
  String get healer2ADescription =>
      "Este cartão cura seus aliados duas vezes mais rápido do que um cartão normal, mas não é muito bom em atacar seus inimigos!";
  @override
  String get healer2BDescription =>
      "Este cartão cura seus aliados duas vezes mais rápido do que um cartão normal, mas tem resistência baixa contra os ataques de seus inimigos!";
  @override
  String get healer2CDescription =>
      "Este cartão cura seus aliados duas vezes mais rápido do que um cartão normal, mas é duas vezes mais lento do que um cartão normal!";
  @override
  String get healer4ADescription =>
      "Este cartão cura seus aliados quatro vezes mais rápido do que um cartão normal, mas não é bom em atacar seus inimigos!";
  @override
  String get healer4BDescription =>
      "Este cartão cura seus aliados quatro vezes mais rápido do que um cartão normal, mas tem resistência muito baixa contra os ataques de seus inimigos!";
  @override
  String get healer4CDescription =>
      "Este cartão cura seus aliados quatro vezes mais rápido do que um cartão normal, mas não se destaca em outras áreas!";
  @override
  String get specialExpansionDescription =>
      "Este cartão aumenta em um o número de possibilidades de ataque do cartão que ele mira, seja o alvo um aliado ou não!";
  @override
  String get specialCompressionDescription =>
      "Este cartão diminui em um o número de possibilidades de ataque do cartão que ele mira, seja o alvo um aliado ou não!";
  @override
  String get specialDecelerationDescription =>
      "Este cartão desacelera seus alvos, reduzindo sua velocidade pela metade. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialAccelerationDescription =>
      "Este cartão acelera seus alvos, multiplicando sua velocidade por dois. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialAttackIncreaseDescription =>
      "Este cartão melhora seus alvos, multiplicando seu ataque por dois. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialAttackDecreaseDescription =>
      "Este cartão diminui o ataque de seus alvos pela metade. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialResistanceIncreaseDescription =>
      "Este cartão melhora a resistência de seus alvos, multiplicando-a por dois. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialResistanceDecreaseDescription =>
      "Este cartão diminui a resistência de seus alvos pela metade. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialSupportIncreaseDescription =>
      "Este cartão melhora o suporte de seus alvos, multiplicando-o por dois. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialSupportDecreaseDescription =>
      "Este cartão diminui o suporte de seus alvos pela metade. Não importa se o alvo é um cartão aliado ou inimigo!";
  @override
  String get specialCloningDescription =>
      "Este é um cartão de vida limitada que permite clonar todas as propriedades e habilidades de um cartão alvo no campo de jogo!";
  @override
  String get specialCancellationDescription =>
      "Este cartão cancela o efeito especial de seus alvos, seja o alvo um aliado ou não. No entanto, ele não pode ser cancelado em troca!";
  @override
  String get specialRefrigerationDescription =>
      "Este cartão impede que seus alvos sejam modificados por seu possuidor, não importa se o alvo é um cartão aliado ou não!";
  @override
  String get specialAspiratorDescription =>
      "Este é um cartão que elimina todos os cartões localizados a uma distância de uma célula dele após um atraso proporcional ao seu nível atual!";
  @override
  String get specialSubstractionDescription =>
      "Este é um cartão que elimina todos os cartões em sua linha e coluna após um atraso proporcional ao seu nível atual!";
  @override
  String get specialDivisionDescription =>
      "Este é um cartão que elimina todos os cartões em suas diagonais após um atraso proporcional ao seu nível atual!";
  @override
  String get specialDeflagrationDescription =>
      "Este é um cartão que elimina todos os cartões em sua linha, coluna e diagonais após um atraso proporcional ao seu nível atual!";
  @override
  String get specialParalysisDescription =>
      "Este é um cartão de vida limitada que impede seus alvos de atacar ou se defender, não importa se o alvo é um cartão aliado ou não!";
  @override
  String get specialInvulnerabilityDescription =>
      "Este é um cartão de vida limitada que torna seus alvos invulneráveis por um período proporcional ao seu nível!";
  @override
  String get specialVortexDescription =>
      "Este é um cartão de vida limitada que permite mover um cartão alvo no campo de jogo trocando de lugar com ele!";

  /* JOGO */

  @override
  String get gameAbandonmentButtonDescription =>
      "Seu oponente será automaticamente declarado o vencedor! Você realmente deseja abandonar este jogo?";
  @override
  String get gameAbandonmentButtonAbandon => "Abandonar";
  @override
  String get gameAbandonmentButtonTitle => "Abandonar";

  @override
  String get gameBottomButtonDisplayResult => "Mostrar Resultado";

  @override
  String get gameCardsSummaryPlay => "Jogar";
  @override
  String get gameCardsSummaryRemember => "Lembre-se bem!";

  @override
  String get gameInitialTutorialPopupPlay => "Jogar";

  @override
  String get gamePassButtonPopupPass => "Passar";
  @override
  String get gamePassButtonPopupDescription =>
      "Antes de continuar, certifique-se de que está familiarizado com as regras do jogo. Você realmente deseja pular o tutorial?";
  @override
  String get gamePassButtonPopupTitle => "Pular Tutorial";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "Parabéns pela vitória! Você passou com sucesso deste nível. Você pode avançar para o próximo nível!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "Você não tem cowries suficientes para jogar o próximo nível! Assista a um anúncio para obter 1 cowrie!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "Você concluiu o modo 'Solitário'!\nJogadores de todo o mundo estão esperando por você no mundo dos jogos online!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "Desculpe pela derrota! Não desanime: você sempre pode melhorar jogando novamente!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "Infelizmente, você não tem cowries suficientes para jogar novamente! Assista a um anúncio para obter 1 cowrie!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "Desculpe pela derrota! De qualquer forma, você já passou deste nível e pode avançar para o próximo!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "Você não tem cowries suficientes para jogar o próximo nível! Assista a um anúncio para obter 1 cowrie!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "Desculpe pela derrota! De qualquer forma, você já concluiu todos os níveis deste modo de jogo!";
  @override
  String get remoteDefeatDescription =>
      "Desculpe pela derrota! Não desanime: você sempre pode melhorar jogando mais jogos!";
  @override
  String get remoteVictoryDescription =>
      "Parabéns pela vitória! Você pode melhorar ainda mais o seu nível participando de mais jogos online!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "Infelizmente, você não tem cowries suficientes para jogar novamente! Assista a um anúncio para obter 1 cowrie!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "O outro jogador não está mais disponível para jogar. Mas ainda existem várias outras opções disponíveis para você!";
  @override
  String get externalNeedinessDescription =>
      "O outro jogador não tem mais cowries suficientes para jogar. Mas você pode esperar por ele ou começar um novo jogo!";
  @override
  String get internalNeedinessTitle => "Cowries Insuficientes!";
  @override
  String get replayImpossibleDescription =>
      "O outro jogador não está mais conectado. Mas você ainda pode começar um novo jogo com outro jogador!";
  @override
  String get invitationWithdrawalDescription =>
      "O outro jogador retirou o convite para jogar novamente. Mas você ainda pode começar um novo jogo!";
  @override
  String get invitationRejectionDescription =>
      "Infelizmente, seu convite foi rejeitado. Mas você ainda pode começar um novo jogo!";
  @override
  String get invitationAcceptationDescription =>
      "Vocês dois estão prontos para jogar novamente. Apenas um pouco de paciência! O jogo será retomado em breve!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "Você não tem cowries suficientes para aceitar um convite! Assista a um anúncio para obter 1 cowrie!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "O outro jogador quer começar um novo jogo com você! Você deseja aceitar ou recusar o convite?";
  @override
  String get internalInvitationDescription =>
      "O outro jogador recebeu uma notificação sobre seu convite para jogar novamente. Eles podem aceitar ou recusar!";
  @override
  String get gamePopupNewGame => "Novo\nJogo";
  @override
  String get gamePopupNextLevel => "Próximo\nNível";
  @override
  String get gamePopupReplay => "Repetir";
  @override
  String get globalExit => "Sair";
  @override
  String get globalAccept => "Aceitar";
  @override
  String get globalReject => "Rejeitar";
  @override
  String get globalCancel => "Cancelar";
  @override
  String get normalDefeatTitle => "Você Perdeu!";
  @override
  String get defeatByAbandonment => "Derrota por Abandono!";
  @override
  String get normalVictoryTitle => "Você Venceu!";
  @override
  String get victoryByAbandonment => "Vitória por Abandono!";
  @override
  String get externalNeedinessTitle => "Ops!";
  @override
  String get internalNeedinessDescription =>
      "O outro jogador gostaria de jogar novamente com você, mas você não tem cowries suficientes para jogar!";
  @override
  String get replayImpossibleTitle => "Repetição Impossível!";
  @override
  String get invitationWithdrawalTitle => "Convite Retirado!";
  @override
  String get invitationRejectionTitle => "Convite Rejeitado!";
  @override
  String get invitationAcceptationTitle => "Carregando o Jogo!";
  @override
  String get externalInvitationTitle => "Você Deseja Jogar Novamente?";
  @override
  String get internalInvitationTitle => "Um Pouco de Paciência!";
  @override
  String get gameProfilePosterClose => "Fechar";
  @override
  String get gameProfilePosterDeck => "Baralho";
  @override
  String get gameProfilePosterCards => "Cartas";
  @override
  String get gameProfilePosterCrowns => "Coroas";

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
  String gameTileNameLevel(int level) => "Nível $level";
  @override
  String get gameTopBarTutorialText => "Tutorial";

  @override
  String get gametutorialCongratulationsPopupPlay => "Jogar";
  @override
  String get gametutorialCongratulationsPopupTitle => "Parabéns!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "Você concluiu esta lição com sucesso! Mas você sempre pode recomeçar se ainda houver áreas escuras!";

  @override
  String get gameTutorialPopupTitle => "Ajuda";

  @override
  String get gameTutorialProgressPopupNextLesson => "Próxima Lição";
  @override
  String get gameTutorialProgressPopupTitle => "Parabéns!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Cowries!";

  @override
  String referralNotificationBody(String name) =>
      "Parabéns! Você recebeu 50 cowries graças ao registro de $name!";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "Não te vemos há vários dias. Venha exercitar seu cérebro enquanto se diverte!";
  @override
  String get notificationMissTitle => "Sentimos sua falta!";
  @override
  String get notificationGiftBody =>
      "A cada hora, você recebe cowries de graça! Venha pegar seu presente!";
  @override
  String get notificationGiftTitle => "Não perca seu presente!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Aguarde a mudança de cor do rei para vencer o jogo.";
  @override
  String get invalidDeckTitle => "Baralho Inválido!";
  @override
  String get invalidDeckDescription =>
      "Seu baralho atual não é válido. Por favor, corrija-o ou selecione outro antes de iniciar um novo jogo!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "Não foi possível conectar à sua conta de jogo. Por favor, verifique sua conexão com a internet e tente novamente!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Erro de Autenticação!";

  @override
  String get globalRetry => "Tentar Novamente";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Autenticação Necessária!";
  @override
  String get authenticationPopupLoadingAuthentication => "Autenticando!";

  @override
  String authenticationPopupDescription(String account) =>
      "Vamos conectá-lo à sua conta $account para salvar seu progresso no jogo!";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Jogos";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Baralho $index";

  @override
  String get cardOptionButtonDescription =>
      "Você pode ter até 3 baralhos. Consulte e selecione seu baralho de jogo aqui.";

  @override
  String get globalValidate => "Validar";

  @override
  String get blockedAccountContactSakiHub => "Contatar o Saki Hub";

  @override
  String get blockedAccountDescription =>
      "O bloqueio da conta é resultado de atividades ilegais ou suspeitas. Se este bloqueio for um erro, por favor, entre em contato conosco!";
  @override
  String get blockedAccountTitle => "Sua Conta Foi Bloqueada!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Cowries aumentam sua liberdade de jogo, mas você precisa estar conectado para usá-los!";
  @override
  String get progressOptionButtonNotAuthenticatedTitle =>
      "Você Não Tem Cowries!";
  @override
  String get progressOptionButtonShowcase =>
      "A cowrie, a moeda do jogo, é essencial para comprar cartas e jogar. Gerencie suas cowries aqui.";

  @override
  String get globalAd => "ANÚNCIO";

  @override
  String get globalConnect => "Conectar";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Atacantes";
  @override
  String get attackerFamilyShortDescription =>
      "Cartas vermelhas: Fortes no ataque";
  @override
  String get attackerFamilyLongDescription =>
      "Essas cartas causam o máximo de dano aos seus inimigos. No entanto, não são excelentes em outras áreas!";

  @override
  String get defenderFamilyName => "Defensores";
  @override
  String get defenderFamilyShortDescription =>
      "Cartas cinzas: Fortes na defesa";
  @override
  String get defenderFamilyLongDescription =>
      "Essas cartas têm os valores de defesa mais altos. No entanto, não são excelentes em outras áreas!";

  @override
  String get healerFamilyName => "Curadores";
  @override
  String get healerFamilyShortDescription => "Cartas verdes: Fortes na cura";
  @override
  String get healerFamilyLongDescription =>
      "Essas cartas curam melhor seus aliados. No entanto, não são excelentes em outras áreas!";

  @override
  String get lordFamilyName => "Senhores";
  @override
  String get lordFamilyShortDescription =>
      "Senhores: Devem ser protegidos a todo custo";
  @override
  String get lordFamilyLongDescription =>
      "Essas são as cartas que devem ser protegidas a todo custo no jogo: você perde automaticamente se a cor do seu senhor mudar!";

  @override
  String get normalFamilyName => "Normais";
  @override
  String get normalFamilyShortDescription =>
      "Cartas marrons: Habilidades equilibradas";
  @override
  String get normalFamilyLongDescription =>
      "Os Normais são os mais equilibrados do jogo. São muito versáteis e oferecem uma verdadeira vantagem no campo!";

  @override
  String get specialFamilyName => "Especiais";
  @override
  String get specialFamilyShortDescription =>
      "Cartas amarelas: Efeitos especiais em outras cartas";
  @override
  String get specialFamilyLongDescription =>
      "Essas cartas têm efeitos em outras cartas. Seus efeitos dependem principalmente de sua natureza!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Lições 1/3: Fundamentos do Jogo";
  @override
  String get globalLesson => "Lições";
  @override
  String get basicsLessonSuffix => "Fundamentos do Jogo";
  @override
  String get basicsLessonWinningMessage =>
      "Parabéns pela sua vitória! Avance rapidamente para a próxima lição e domine o papel das cartas do jogo!";

  @override
  String get normalLessonTitle => "Lições 2/3: Papel das Cartas";
  @override
  String get normalLessonSuffix => "Papel das Cartas";
  @override
  String get specialLessonSuffix => "Cartas Especiais";
  @override
  String get normalLessonDescription =>
      "As cartas vermelhas são boas para atacar, as verdes são de suporte, as cinzas são de resistência e as marrons são equilibradas!";
  @override
  String get normalLessonWinningMessage =>
      "Parabéns pela sua vitória! Continue com a próxima lição para entender o papel das cartas amarelas!";

  @override
  String get specialLessonTitle => "Lições 3/3: Cartas Especiais";
  @override
  String get specialLessonDescription =>
      "As cartas amarelas têm efeitos especiais sobre as outras. O efeito de uma carta especial depende apenas de sua natureza!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Incrível";
  @override
  String get congratulationsMessage => "Parabéns";
  @override
  String get excellentMessage => "Excelente";
  @override
  String get goodMessage => "Bom";
  @override
  String get greatMessage => "Ótimo";
  @override
  String get magnificentMessage => "Magnífico";
  @override
  String get masterfulMessage => "Magistral";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "Coloque uma de suas cartas no campo de jogo para aumentar seus aliados.";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Conecte-se à carta cinza para torná-la um aliado do reino.";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Aguarde até que a carta cinza mude de cor para poder usá-la.";
  @override
  String get basicsCutPathInstruction =>
      "Remova a conexão entre as duas cartas conforme indicado.";
  @override
  String get basicsConnectKingInstruction =>
      "Conecte-se ao rei adversário para começar a atacá-lo.";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Você precisa contra-atacar. Coloque um atacante no campo de jogo.";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "O adversário jogou um cidadão. Ataque antes que ele ataque você.";
  @override
  String get normalPlaceHealerInstruction =>
      "Seu rei está sob ataque e precisa ser curado. Coloque um curandeiro no campo de jogo.";
  @override
  String get normalConnectHealerInstruction =>
      "Cure rapidamente seu rei para evitar que ele mude de cor.";
  @override
  String get normalPlaceAttackerInstruction =>
      "Você precisa contra-atacar. Coloque um atacante no campo de jogo.";
  @override
  String get normalConnectAttackerInstruction =>
      "Ataque a carta que está atacando você para proteger o rei.";
  @override
  String get normalConquerAttackerInstruction =>
      "Aguarde até que a carta da esquerda mude de cor para poder usá-la.";
  @override
  String get normalPlaceDefenderInstruction =>
      "Seu cidadão foi derrotado. Coloque um defensor para proteger seu rei.";
  @override
  String get normalConnectDefenderInstruction =>
      "Defenda seu rei atacando a carta que ameaça seu rei.";
  @override
  String get normalConnectKingInstruction =>
      "Você está sendo atacado, mas mantenha o foco no rei adversário.";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Você precisa contra-atacar. Coloque um atacante no campo de jogo.";
  @override
  String get specialPlaceCompressionInstruction =>
      "O adversário contra-atacou. Use COMPRESSÃO para se defender.";
  @override
  String get specialConnectCompressionInstruction =>
      "A COMPRESSÃO é usada para eliminar uma conexão de seus alvos. Use-a.";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "O adversário está insistindo. Use REFRIGERAÇÃO para congelar o inimigo.";
  @override
  String get specialConnectRefrigerationInstruction =>
      "A REFRIGERAÇÃO impede que seus alvos sejam alterados. Use-a.";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "A carta congelada está à sua mercê. Ataque-a para convertê-la em aliada.";
  @override
  String get specialPlaceExpansionInstruction =>
      "O adversário está persistindo. Use EXPANSÃO para se defender.";
  @override
  String get specialConnectExpansionInstruction =>
      "A EXPANSÃO aumenta as conexões de seus alvos. Use-a.";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Graças à EXPANSÃO, você pode atacar 2 cartas alvo. Vamos lá!";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Aguarde até que a carta da direita mude de cor para poder usá-la.";
  @override
  String get specialConnectKingInstruction =>
      "Termine este tutorial com um ataque ao rei adversário.";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get basicsConnectCenterTileDescription =>
      "Para se conectar à carta cinza, arraste-a da carta que você acabou de colocar até a carta cinza!";
  @override
  String get basicsConquerCenterTileDescription =>
      "Para que a cor da carta cinza mude, você precisa ter uma conexão com ela e reduzir seus pontos para 0!";
  @override
  String get basicsCutPathDescription =>
      "Para remover a conexão entre as duas cartas, faça um gesto de deslizar para traçar um segmento que corta a ligação!";
  @override
  String get basicsConnectKingDescription =>
      "Para se conectar ao rei adversário, arraste-a da carta que você acabou de colocar até o rei!";
  @override
  String get kingConquestDescription =>
      "Para que a cor da carta do rei mude, você precisa ter uma conexão com ela e reduzir seus pontos para 0!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "Para se conectar à carta alvo, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get normalPlaceHealerDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get normalConnectHealerDescription =>
      "Para curar rapidamente seu rei, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get normalPlaceAttackerDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get normalConnectAttackerDescription =>
      "Para se conectar à carta alvo, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get normalConquerAttackerDescription =>
      "Para que a cor da carta alvo mude, você precisa ter uma conexão com ela e reduzir seus pontos para 0!";
  @override
  String get normalPlaceDefenderDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get normalConnectDefenderDescription =>
      "Para defender seu rei, ataque a carta que ameaça seu rei!";
  @override
  String get normalConnectKingDescription =>
      "Para proteger seu rei, ataque o rei adversário!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get specialPlaceCompressionDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get specialConnectCompressionDescription =>
      "Para eliminar uma conexão de seus alvos, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get specialConnectRefrigerationDescription =>
      "Para evitar que seus alvos sejam alterados, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "Para transformar a carta congelada em um aliado, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get specialPlaceExpansionDescription =>
      "Para colocar uma carta no campo de jogo, arraste-a da carta para a posição desejada!";
  @override
  String get specialConnectExpansionDescription =>
      "Para aumentar as conexões de seus alvos, arraste-a da carta original para a carta que você está mirando!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "Graças à EXPANSÃO, você pode atacar 2 cartas alvo. Vamos lá!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "Aguarde até que a carta da direita mude de cor para poder usá-la!";
  @override
  String get specialConnectKingDescription =>
      "Termine este tutorial com um golpe maestro atacando o rei adversário!";

  /* SKILLS */

  @override
  String get attackSkillNull => "Nulo";
  @override
  String get attackSkillVeryBad => "Muito Ruim";
  @override
  String get attackSkillBad => "Ruim";
  @override
  String get attackSkillNormal => "Normal";
  @override
  String get attackSkillGood => "Bom";
  @override
  String get attackSkillVeryGood => "Muito Bom";

  @override
  String get supportSkillNull => "Nulo";
  @override
  String get supportSkillVeryBad => "Muito Ruim";
  @override
  String get supportSkillBad => "Ruim";
  @override
  String get supportSkillNormal => "Normal";
  @override
  String get supportSkillGood => "Bom";
  @override
  String get supportSkillVeryGood => "Muito Bom";

  @override
  String get resistanceSkillNull => "Nulo";
  @override
  String get resistanceSkillVeryBad => "Muito Ruim";
  @override
  String get resistanceSkillBad => "Ruim";
  @override
  String get resistanceSkillNormal => "Normal";
  @override
  String get resistanceSkillGood => "Bom";
  @override
  String get resistanceSkillVeryGood => "Muito Bom";

  @override
  String get lifeSkillNull => "Nulo";
  @override
  String get lifeSkillHalf => "Metade";
  @override
  String get lifeSkillNormal => "Normal";

  @override
  String get speedSkillNull => "Nulo";
  @override
  String get speedSkillHalf => "Metade";
  @override
  String get speedSkillNormal => "Normal";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "Fechar esta parte custará exatamente $cowries cauris! Você realmente deseja fechar o jogo?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "Fechar esta parte custará exatamente $cowries cauris! Você realmente deseja fechar o jogo?";
  @override
  String get adventureSimpleCloseDescription =>
      "Fechar o jogo atual resultará na perda do seu progresso! Você realmente deseja fechar o jogo atual?";
  @override
  String get remoteSimpleCloseDescription =>
      "Fechar esta parte resultará na perda de seu progresso atual! Você realmente deseja fechar esta parte?";
  @override
  String get closeClose => "Fechar";
  @override
  String get closeTitle => "Fechar";

  @override
  String get watchAdButtonRefreshAd => "Atualizar anúncio";
  @override
  String get cardOptionButtonPopupSelectDeck => "Selecionar este baralho";

  @override
  String get lessonChangeTitle => "Mudança de Lição";
  @override
  String get lessonChangeDescription =>
      "Por favor, domine os ensinamentos desta lição antes de passar para outra! Você realmente deseja mudar de lição?";
  @override
  String get lessonChangeAction => "Mudar";

  @override
  String get restoreDefaultLanguage => "Restaurar o idioma padrão";

  //

  @override
  String get loadingDescription =>
      "Estamos carregando os dados do jogo. Por favor, espere um momento!";
  @override
  String get homeUpdateSimpleDescription =>
      "Uma nova versão do jogo está disponível. Instale-a rapidamente para desfrutar dos recursos mais recentes!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "Agora você pode entrar no universo do jogo e explorar todas as suas complexidades!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "Eu sou a inteligência artificial do nível $level do jogo! Farei o meu melhor para lhe proporcionar um ótimo jogo!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "Eu sou a inteligência artificial do tutorial do jogo. Basta seguir as instruções para ganhar!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "Transação cancelada!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "Não pudemos validar sua compra. Por favor, verifique seu método de pagamento e sua conexão com a internet!";

  @override
  String get drawTitle => "Empate!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "Você terminou em empate! De qualquer forma, você já completou todos os níveis deste modo de jogo!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "Você terminou em empate! De qualquer forma, você já passou deste nível e pode ir para o próximo nível!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "Você terminou em empate! Você ainda pode vencer jogando novamente contra a IA!";
  @override
  String get remoteDrawDescription =>
      "Você não ganhou nem perdeu! Por que não começar outra partida com o outro jogador para desempatar?";
  @override
  String get newPlayer => "Novo jogador";

  @override
  String get premiumButtonRemoveAds => "Remover anúncios";
}
