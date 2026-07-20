import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageRu extends GamicoLanguages {
  @override
  String get globalMax => "МАКС";
  @override
  String get globalRefresh => "Обновить";
  @override
  String get globalClose => "Закрыть";
  @override
  String get globalOK => "OK";

  /* FRIEND */

  @override
  String get friendPageTitle => "Поиск друзей";

  @override
  String get friendPageSearchHint => "Поиск по имени...";

  @override
  String get friendPagePendingInvitations => "Ожидающие приглашения";

  @override
  String get friendPageGameInvitation => "Приглашение в игру";

  @override
  String friendPageInvitationFrom(String name) => "От: $name";

  @override
  String get friendPageInvitationSent => "Приглашение отправлено!";

  @override
  String get friendPageFailedToSendInvitation =>
      "Не удалось отправить приглашение";

  @override
  String get friendPageUnknown => "Неизвестно";
  @override
  String get notificationInvitationBody => "Вы получили приглашение в игру!";
  @override
  String notificationInvitationFrom(String name) => "$name приглашает вас сыграть!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Помощь";
  @override
  String get adventureHelpDescription =>
      "Вы можете выбрать уровень, нажав на него. Но если вы еще не очень хорошо играете, следуйте инструкциям!";
  @override
  String get adventureClose => "Закрыть";
  @override
  String get adventureFollow => "Следовать";

  @override
  String adventureChapterChapter(int chapter) => "Глава $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Семья: $family";
  @override
  String get collectionCardPopupUpgrade => "Улучшить";
  @override
  String get collectionCardPopupRemove => "Удалить";
  @override
  String get collectionCardPopupUse => "Использовать";
  @override
  String get collectionCardPopupAcquire => "Приобрести";

  @override
  String get collectionCardSkillsAttack => "Атака";
  @override
  String get collectionCardSkillsSupport => "Поддержка";
  @override
  String get collectionCardSkillsResistance => "Сопротивление";
  @override
  String get collectionCardSkillsTheoreticalLife => "Теоретическая жизнь";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "Теоретическая скорость";
  @override
  String get collectionCardSkillsPower => "Сила";
  @override
  String get collectionCardSkillsConcreteLife => "Фактическая жизнь";
  @override
  String get collectionCardSkillsConcreteSpeed => "Фактическая скорость";
  @override
  String get collectionCardSkillsConnections => "Связи";

  @override
  String collectionCardSquareLevel(int level) => "Уровень $level";

  @override
  String get collectionCardBlocked => "Заблокировано";
  @override
  String collectionCardLevel(int level) => "Уровень $level";

  @override
  String get collectionContentDeck => "Колоды";
  @override
  String get collectionContentUnlockedCards => "Разблокированные карты";
  @override
  String get collectionContentRemainingCards => "Оставшиеся карты";

  /* HOME */

  @override
  String get homeLanguagesTitle => "Языки";

  @override
  String get homeMultiplayerButtonShowcase =>
      "Эта кнопка позволяет вам играть в игры с другими игроками онлайн.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "Эта кнопка позволяет вам играть в игры с искусственным интеллектом игры.";
  @override
  String get homeNotificationsTitle => "Уведомления";
  @override
  String get homeNotificationsDescription =>
      "Для улучшения вашего игрового опыта вы должны разрешить уведомления! Хотите разрешить уведомления?";
  @override
  String get homeNotificationsAllow => "Разрешить";
  @override
  String get homeNotificationsReminderTitle => "Включить уведомления";
  @override
  String get homeNotificationsReminderDescription =>
      "Уведомления важны для лучшего игрового опыта. Хотите включить их сейчас?";
  @override
  String get homeUpdateTitle => "Доступно обновление!";
  @override
  String get homeUpdateForceDescription =>
      "В новой версии исправлено множество ошибок и проблем. Установите ее быстро, чтобы воспользоваться этими исправлениями!";
  @override
  String get homeUpdateInstall => "Установить";

  @override
  String get homeAbout => "О нас";
  @override
  String homeAboutPopupShareText(String link) =>
      "Я нашел очень интересную стратегическую игру! Скачайте ее бесплатно по ссылке: $link!";
  @override
  String get homeAboutPopupImplementation => "Реализация";
  @override
  String get homeAboutPopupMusic => "Музыка";
  @override
  String get homeAboutPopupVersion => "Версия";
  @override
  String get homeAboutPopupRateGame => "Оценить игру";
  @override
  String get homeAboutPopupVisitWebstie => "Посетить Saki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "Посмотреть мои приложения";

  @override
  String get homeCardPresentationShowcase =>
      "Используйте это меню, чтобы покупать новые карты и улучшать уже имеющиеся.";
  @override
  String get homeCardPresentationShow => "Показать все карты";

  @override
  String get homeGratificationPopupConnectionErrorTitle =>
      "Ошибка подключения!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Пожалуйста, проверьте ваше интернет-соединение. Этот раздел обновится автоматически, когда вы подключитесь!";
  @override
  String get homeGratificationPopupLoadingTitle => "Загрузка наград!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "Награды будут доступны всего через несколько секунд. Пожалуйста, подождите!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Неверный временной штамп!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle =>
      "Проблема с соединением!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "Похоже, у вас нет подключения к интернету. Пожалуйста, проверьте качество вашего интернет-соединения и попробуйте снова!";
  @override
  String get homeMultiplayerButtonText => "Мульти";

  @override
  String get homeProfilePopupBestTacticians => "Лучшие тактики";
  @override
  String get homeProfilePopupDescription =>
      "Игроки классифицируются на основе двух критериев: количество побед в онлайне и максимальное количество каури!";
  @override
  String get homeProfilePopupBestCollectors => "Лучшие коллекционеры";
  @override
  String get homeProfilePopupCheckAchievements => "Посмотреть мои достижения";

  @override
  String get homeSingleplayerButtonText => "Один игрок";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "Специальные предложения активируются каждые 3 дня и действительны всего 24 часа. Не упустите следующее!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "Специальные предложения активируются каждые 3 дня и действительны всего 24 часа. Так что, что же вы ждете, чтобы воспользоваться?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Данные, связанные с специальным предложением, скоро будут доступны. Пожалуйста, подождите немного!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "Мы не смогли подтвердить вашу покупку. Пожалуйста, проверьте ваш метод оплаты и подключение к интернету!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle!";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "Загрузка предложения!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Отмена транзакции!";
  @override
  String get homeSpecialOfferPopupClose => "Закрыть";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "Неверная отметка времени!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Данные, связанные с специальным предложением, скоро будут доступны. Пожалуйста, подождите немного!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Загрузка предложения!";
  @override
  String get homeSpecialOfferPopupProblemClose => "Закрыть";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Проблема с соединением!";

  @override
  String get homeHelpBasicsA =>
      "Королевство Синих сталкивается с королевством Оранжевых.";
  @override
  String get homeHelpBasicsB =>
      "Можно победить, изменив цвет вражеского лорда.";
  @override
  String get homeHelpBasicsC =>
      "Можно победить, имея большинство жизненных очков в выделенное время.";

  @override
  String get homeHelpConnections1A =>
      "Вы можете нажать и перетащить, чтобы соединить две карты.";
  @override
  String get homeHelpConnections1B =>
      "Вы можете нажать и коснуться, чтобы соединить две карты.";
  @override
  String get homeHelpConnections1C =>
      "Вы можете разорвать соединение свайпом пальца.";

  @override
  String get homeHelpConnections2A =>
      "Иногда соединение может затруднить возможность игры.";
  @override
  String get homeHelpConnections2B =>
      "Нельзя перепрыгнуть через одну карту, чтобы соединиться с другой.";
  @override
  String get homeHelpConnections2C =>
      "Карта в режиме МАКС возвращает все мячи, которые она получает.";

  @override
  String get homeHelpCards1A => "Красные карты хороши для атаки.";
  @override
  String get homeHelpCards1B => "Серые карты хороши для сопротивления.";
  @override
  String get homeHelpCards1C => "Зеленые карты хороши для поддержки.";

  @override
  String get homeHelpCards2A =>
      "Коричневые карты имеют сбалансированные способности.";
  @override
  String get homeHelpCards2B =>
      "Желтые карты имеют специальные эффекты на другие карты.";
  @override
  String get homeHelpCards2C =>
      "Белые карты - те, которые необходимо защищать любой ценой.";

  @override
  String get homeHelpRestrictionsA =>
      "Каждое соединение должно быть полезным. Здесь оно бесполезно и, следовательно, невозможно.";
  @override
  String get homeHelpRestrictionsB =>
      "Карта уничтожения не может атаковать лорда.";
  @override
  String get homeHelpRestrictionsC =>
      "Нельзя клонировать или перемещать лорда.";

  /* LOADING */

  @override
  String get loadingTitle => "Пожалуйста, подождите!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Проблема с подключением!";
  @override
  String get remoteConnexionProblemDescription =>
      "Извините! Ваше интернет-подключение было отключено. Вас объявили проигравшим в игре!";
  @override
  String get remoteInvitationTitle => "Приходите и играйте!";
  @override
  String get remoteInvitationDescription => "Ваша онлайн-игра началась!";
  @override
  String get remoteMultiplayer => "Многопользователь";

  @override
  String get remoteFailurePosterTitle => "Произошла ошибка!";
  @override
  String get remoteFailurePosterDescription =>
      "Произошла ошибка во время поиска. Проверьте ваше интернет-подключение и попробуйте еще раз!";

  @override
  String get remoteImpossibleGamePosterTitle => "Недостаточно каури!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "Для игры в сети вам необходимо иметь как минимум $cowries каури!";

  @override
  String get remoteNewGamePosterTitle => "Новая игра?";
  @override
  String get remoteNewGamePosterDescription =>
      "Вы все еще можете играть с игроками со всего мира, чтобы повысить свой уровень!";

  @override
  String get remoteSearchPosterTitle => "Поиск игроков";
  @override
  String get remoteSearchPosterDescription =>
      "Мы ищем игроков по всему миру, чтобы сыграть с вами!";

  @override
  String get homeTranslationPopupDescription =>
      "Этот раздел позволяет выбрать основной язык игры. Нажмите на язык, чтобы активировать его автоматически!";

  /* ЗАГОЛОВКИ КАРТ */

  @override
  String get lordLazyKingName => "Ленивый Король";
  @override
  String get lordLazyQueenName => "Хрупкая Королева";
  @override
  String get lordLazyPrinceName => "Одинокий Принц";
  @override
  String get lordLazyPrincessName => "Замкнутая Принцесса";
  @override
  String get lordCourageousKingName => "Прагматичный Король";
  @override
  String get lordCourageousQueenName => "Бесстрашная Королева";
  @override
  String get lordCourageousPrinceName => "Крепкий Принц";
  @override
  String get lordCourageousPrincessName => "Преданная Принцесса";
  @override
  String get normalOrdinaryCitizenName => "Обычный Гражданин";
  @override
  String get normalAttackerDefenderName => "Военный Страж";
  @override
  String get normalAttackerHealerName => "Военный Медик";
  @override
  String get normalDefenderHealerName => "Страж-Медик";
  @override
  String get attacker2AName => "Грипп";
  @override
  String get attacker2BName => "Солнце";
  @override
  String get attacker2CName => "Искра";
  @override
  String get attacker4AName => "Вихрь";
  @override
  String get attacker4BName => "Комар";
  @override
  String get attacker4CName => "Циклон";
  @override
  String get defender2AName => "Камень";
  @override
  String get defender2BName => "Галька";
  @override
  String get defender2CName => "Вал";
  @override
  String get defender4AName => "Луч";
  @override
  String get defender4BName => "Балкон";
  @override
  String get defender4CName => "Окно";
  @override
  String get healer2AName => "Трава";
  @override
  String get healer2BName => "Цветок";
  @override
  String get healer2CName => "Лист";
  @override
  String get healer4AName => "Куст";
  @override
  String get healer4BName => "Пластырь";
  @override
  String get healer4CName => "Дерево";
  @override
  String get specialExpansionName => "Расширение";
  @override
  String get specialCompressionName => "Сжатие";
  @override
  String get specialDecelerationName => "Замедление";
  @override
  String get specialAccelerationName => "Ускорение";
  @override
  String get specialAttackIncreaseName => "Мужество";
  @override
  String get specialAttackDecreaseName => "Трусость";
  @override
  String get specialResistanceIncreaseName => "Укрепление";
  @override
  String get specialResistanceDecreaseName => "Ослабление";
  @override
  String get specialSupportIncreaseName => "Альтруизм";
  @override
  String get specialSupportDecreaseName => "Индивидуализм";
  @override
  String get specialCloningName => "Клонирование";
  @override
  String get specialCancellationName => "Отмена";
  @override
  String get specialRefrigerationName => "Охлаждение";
  @override
  String get specialAspiratorName => "Бездна";
  @override
  String get specialSubstractionName => "Вычитание";
  @override
  String get specialDivisionName => "Деление";
  @override
  String get specialDeflagrationName => "Дефлаграция";
  @override
  String get specialParalysisName => "Паралич";
  @override
  String get specialInvulnerabilityName => "Неуязвимость";
  @override
  String get specialVortexName => "Вихрь";

  /* ОПИСАНИЯ КАРТ */

  @override
  String get lordLazyKingDescription =>
      "Это единственный лорд, который не может ни атаковать, ни защищаться. Тем не менее, это сбалансированный король, у которого нет конкретных слабых мест!";
  @override
  String get lordLazyQueenDescription =>
      "Это дама, очень хорошо атакующая и поддерживающая своих подданных, несмотря на свой возраст. Однако ее сопротивление оставляет желать лучшего!";
  @override
  String get lordLazyPrinceDescription =>
      "Это молодой человек, очень хорошо атакующий и сопротивляющийся атакам. Однако он не умеет поддерживать своих подданных!";
  @override
  String get lordLazyPrincessDescription =>
      "Это молодая женщина, очень хорошо сопротивляющаяся атакам и поддерживающая своих подданных. Однако она не сильна в атаке!";
  @override
  String get lordCourageousKingDescription =>
      "Это сбалансированный король, у которого нет конкретных слабых мест. Однако у него в два раза меньше жизненных очков, чем обычно!";
  @override
  String get lordCourageousQueenDescription =>
      "Это дама, чрезвычайно хорошо атакующая, несмотря на свой возраст. Но она не выделяется в других областях!";
  @override
  String get lordCourageousPrinceDescription =>
      "Это молодой человек, чрезвычайно хорошо сопротивляющийся атакам. Но этот принц не выделяется в других областях!";
  @override
  String get lordCourageousPrincessDescription =>
      "Это молодая женщина, чрезвычайно хорошо поддерживающая своих подданных. Но эта принцесса не выделяется в других областях!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "Эта карта самая сбалансированная в игре. У нее нет конкретных сильных или слабых сторон, но она все равно надежный союзник!";
  @override
  String get normalAttackerDefenderDescription =>
      "Как следует из названия, это молодой человек, хорошо атакующий своих врагов и одновременно сопротивляющийся их атакам!";
  @override
  String get normalAttackerHealerDescription =>
      "Как следует из названия, это молодой человек, хорошо атакующий своих врагов и поддерживающий своих союзников!";
  @override
  String get normalDefenderHealerDescription =>
      "Как следует из названия, это молодой человек, хорошо поддерживающий своих союзников и сопротивляющийся атакам своих врагов!";
  @override
  String get attacker2ADescription =>
      "Эта карта наносит своим врагам в два раза больше урона, чем обычная карта, но не очень хорошо поддерживает своих союзников!";
  @override
  String get attacker2BDescription =>
      "Эта карта наносит своим врагам в два раза больше урона, чем обычная карта, но имеет низкое сопротивление атакам своих врагов!";
  @override
  String get attacker2CDescription =>
      "Эта карта наносит своим врагам в два раза больше урона, чем обычная карта, но дважды медленнее обычной карты!";
  @override
  String get attacker4ADescription =>
      "Эта карта наносит своим врагам в четыре раза больше урона, чем обычная карта, но не очень хорошо поддерживает своих союзников!";
  @override
  String get attacker4BDescription =>
      "Эта карта наносит своим врагам в четыре раза больше урона, чем обычная карта, но имеет очень низкое сопротивление атакам своих врагов!";
  @override
  String get attacker4CDescription =>
      "Эта карта наносит своим врагам в четыре раза больше урона, чем обычная карта, но не выделяется в других областях!";
  @override
  String get defender2ADescription =>
      "Эта карта имеет дважды больше сопротивление, чем обычная карта, но не очень хорошо атакует своих врагов!";
  @override
  String get defender2BDescription =>
      "Эта карта имеет дважды больше сопротивление, чем обычная карта, но не очень хорошо поддерживает своих союзников!";
  @override
  String get defender2CDescription =>
      "Эта карта имеет дважды больше сопротивление, чем обычная карта, но дважды медленнее обычной карты!";
  @override
  String get defender4ADescription =>
      "Эта карта имеет четырежды больше сопротивление, чем обычная карта, но не очень хорошо атакует своих врагов!";
  @override
  String get defender4BDescription =>
      "Эта карта имеет четырежды больше сопротивление, чем обычная карта, но не очень хорошо поддерживает своих союзников!";
  @override
  String get defender4CDescription =>
      "Эта карта имеет четырежды больше сопротивление, чем обычная карта, но не выделяется в других областях!";
  @override
  String get healer2ADescription =>
      "Эта карта лечит своих союзников в два раза быстрее, чем обычная карта, но не очень хорошо атакует своих врагов!";
  @override
  String get healer2BDescription =>
      "Эта карта лечит своих союзников в два раза быстрее, чем обычная карта, но имеет низкое сопротивление атакам своих врагов!";
  @override
  String get healer2CDescription =>
      "Эта карта лечит своих союзников в два раза быстрее, чем обычная карта, но дважды медленнее обычной карты!";
  @override
  String get healer4ADescription =>
      "Эта карта лечит своих союзников в четыре раза быстрее, чем обычная карта, но не очень хорошо атакует своих врагов!";
  @override
  String get healer4BDescription =>
      "Эта карта лечит своих союзников в четыре раза быстрее, чем обычная карта, но имеет очень низкое сопротивление атакам своих врагов!";
  @override
  String get healer4CDescription =>
      "Эта карта лечит своих союзников в четыре раза быстрее, чем обычная карта, но не выделяется в других областях!";
  @override
  String get specialExpansionDescription =>
      "Эта карта увеличивает на один количество возможных атак цели, будь то союзник или нет!";
  @override
  String get specialCompressionDescription =>
      "Эта карта уменьшает на один количество возможных атак цели, будь то союзник или нет!";
  @override
  String get specialDecelerationDescription =>
      "Эта карта замедляет своих целей, уменьшая их скорость вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialAccelerationDescription =>
      "Эта карта ускоряет своих целей, увеличивая их скорость вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialAttackIncreaseDescription =>
      "Эта карта увеличивает атаку своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialAttackDecreaseDescription =>
      "Эта карта уменьшает атаку своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialResistanceIncreaseDescription =>
      "Эта карта увеличивает сопротивление своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialResistanceDecreaseDescription =>
      "Эта карта уменьшает сопротивление своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialSupportIncreaseDescription =>
      "Эта карта увеличивает поддержку своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialSupportDecreaseDescription =>
      "Эта карта уменьшает поддержку своих целей вдвое. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialCloningDescription =>
      "Эта карта с ограниченным сроком службы позволяет клонировать все свойства и способности выбранной карты на поле боя!";
  @override
  String get specialCancellationDescription =>
      "Эта карта отменяет специальный эффект своих целей, будь то союзник или нет. Однако ее нельзя отменить взамен!";
  @override
  String get specialRefrigerationDescription =>
      "Эта карта предотвращает изменение своих целей их владельцем, будь то союзный или нет!";
  @override
  String get specialAspiratorDescription =>
      "Эта карта уничтожает все карты, находящиеся на расстоянии одной ячейки от нее, после задержки, пропорциональной ее текущему уровню!";
  @override
  String get specialSubstractionDescription =>
      "Эта карта уничтожает все карты в своей строке и столбце после задержки, пропорциональной ее текущему уровню!";
  @override
  String get specialDivisionDescription =>
      "Эта карта уничтожает все карты на своих диагоналях после задержки, пропорциональной ее текущему уровню!";
  @override
  String get specialDeflagrationDescription =>
      "Эта карта уничтожает все карты в своей строке, столбце и диагоналях после задержки, пропорциональной ее текущему уровню!";
  @override
  String get specialParalysisDescription =>
      "Эта карта с ограниченным сроком службы лишает свои цели возможности атаковать или защищаться. Неважно, является ли целью союзный или враждебный карт!";
  @override
  String get specialInvulnerabilityDescription =>
      "Эта карта с ограниченным сроком службы делает свои цели невосприимчивыми к урону на период, пропорциональный ее текущему уровню!";
  @override
  String get specialVortexDescription =>
      "Эта карта с ограниченным сроком службы позволяет переместить выбранную карту на поле боя, поменявшись с ней местами!";

  /* ИГРА */

  @override
  String get gameAbandonmentButtonDescription =>
      "Ваш противник будет автоматически объявлен победителем! Вы действительно хотите покинуть эту игру?";
  @override
  String get gameAbandonmentButtonAbandon => "Покинуть";
  @override
  String get gameAbandonmentButtonTitle => "Покинуть";

  @override
  String get gameBottomButtonDisplayResult => "Показать результат";

  @override
  String get gameCardsSummaryPlay => "Играть";
  @override
  String get gameCardsSummaryRemember => "Хорошо помните!";

  @override
  String get gameInitialTutorialPopupPlay => "Играть";

  @override
  String get gamePassButtonPopupPass => "Пропустить";
  @override
  String get gamePassButtonPopupDescription =>
      "Прежде чем продолжить, убедитесь, что вы хорошо знакомы с правилами игры. Вы действительно хотите пропустить обучение?";
  @override
  String get gamePassButtonPopupTitle => "Пропустить обучение";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "Поздравляю с победой! Вы успешно прошли этот уровень. Вы можете перейти к следующему уровню!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "У вас недостаточно ракушек, чтобы играть на следующем уровне! Посмотрите рекламу, чтобы получить 1 ракушку!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "Вы завершили режим 'Пасьянс'!\nИгроки со всего мира ждут вас в мире онлайн-игр!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "Извините за поражение! Не унывайте: вы всегда можете улучшиться, сыграв еще раз!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "К сожалению, у вас недостаточно ракушек, чтобы играть снова! Посмотрите рекламу, чтобы получить 1 ракушку!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "Извините за поражение! В любом случае, вы уже прошли этот уровень и можете перейти к следующему!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "У вас недостаточно ракушек, чтобы играть на следующем уровне! Посмотрите рекламу, чтобы получить 1 ракушку!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "Извините за поражение! В любом случае, вы уже завершили все уровни этого режима игры!";
  @override
  String get remoteDefeatDescription =>
      "Извините за поражение! Не унывайте: вы всегда можете улучшиться, сыграв больше игр!";
  @override
  String get remoteVictoryDescription =>
      "Поздравляю с победой! Вы можете дальше улучшать свой уровень, участвуя в большем количестве онлайн-игр!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "К сожалению, у вас недостаточно ракушек, чтобы играть снова! Посмотрите рекламу, чтобы получить 1 ракушку!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "Другой игрок больше не доступен для игры. Но у вас всегда есть много других вариантов!";
  @override
  String get externalNeedinessDescription =>
      "Другой игрок больше не имеет достаточно ракушек, чтобы играть. Но вы можете подождать его или начать новую игру!";
  @override
  String get internalNeedinessTitle => "Недостаточно ракушек!";
  @override
  String get replayImpossibleDescription =>
      "Другой игрок больше не подключен. Но вы всегда можете начать новую игру с другим игроком!";
  @override
  String get invitationWithdrawalDescription =>
      "Другой игрок отменил свое приглашение на повторную игру. Но вы всегда можете начать новую игру!";
  @override
  String get invitationRejectionDescription =>
      "К сожалению, ваше приглашение было отклонено. Но вы всегда можете начать новую игру!";
  @override
  String get invitationAcceptationDescription =>
      "Вы оба готовы играть еще раз. Немного терпения! Игра возобновится через несколько моментов!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "У вас недостаточно ракушек, чтобы принять приглашение! Посмотрите рекламу, чтобы получить 1 ракушку!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "Другой игрок хочет начать новую игру с вами! Хотите принять или отклонить его приглашение?";
  @override
  String get internalInvitationDescription =>
      "Другой игрок получил уведомление о вашем приглашении на повторную игру. Он может принять или отклонить его!";
  @override
  String get gamePopupNewGame => "Новая\nигра";
  @override
  String get gamePopupNextLevel => "Следующий\nуровень";
  @override
  String get gamePopupReplay => "Повторно\nиграть";
  @override
  String get globalExit => "Выход";
  @override
  String get globalAccept => "Принять";
  @override
  String get globalReject => "Отклонить";
  @override
  String get globalCancel => "Отменить";
  @override
  String get normalDefeatTitle => "Вы проиграли!";
  @override
  String get defeatByAbandonment => "Поражение из-за покидания!";
  @override
  String get normalVictoryTitle => "Вы победили!";
  @override
  String get victoryByAbandonment => "Победа из-за покидания!";
  @override
  String get externalNeedinessTitle => "Упс!";
  @override
  String get internalNeedinessDescription =>
      "Другой игрок хочет сыграть еще одну игру с вами, но у вас недостаточно ракушек, чтобы играть!";
  @override
  String get replayImpossibleTitle => "Невозможно повторить!";
  @override
  String get invitationWithdrawalTitle => "Приглашение отозвано!";
  @override
  String get invitationRejectionTitle => "Приглашение отклонено!";
  @override
  String get invitationAcceptationTitle => "Загрузка игры!";
  @override
  String get externalInvitationTitle => "Хотите играть еще раз?";
  @override
  String get internalInvitationTitle => "Немного терпения!";
  @override
  String get gameProfilePosterClose => "Закрыть";
  @override
  String get gameProfilePosterDeck => "Колода";
  @override
  String get gameProfilePosterCards => "Карты";
  @override
  String get gameProfilePosterCrowns => "Короны";

  @override
  List<String> get names => [
    "Алекс",
    "Соня",
    "Базиль",
    "Йоанн",
    "Айзек",
    "Роберто",
    "Танги",
    "Джессе",
    "Алиса",
    "Христиан",
    "Фабьен",
    "Мими",
    "Морис",
    "Люси",
    "Жозиан",
    "Вьян",
    "Аничетт",
    "Аделин",
    "Бенедикт",
    "Роза",
    "Дебора",
    "Анж",
    "Клеманс",
    "Од",
    "Мирей",
    "Сесиль",
    "Лоранс",
    "Мариус",
    "Надеж",
    "Сильви",
    "Кларисс",
    "Клод",
    "Клотильд",
    "Андре",
    "Кристина",
    "Леопольд",
    "Женевьев",
    "Эсфер",
    "Флор",
    "Анжелика",
    "Дженнифер",
    "Юг",
    "Югет",
    "Оливье",
    "Жюдит",
    "Мартин",
    "Рашель",
    "Антуан",
    "Альфред",
    "Марта",
    "Боб",
  ];

  @override
  String gameTileNameLevel(int level) => "Уровень $level";
  @override
  String get gameTopBarTutorialText => "Урок";

  @override
  String get gametutorialCongratulationsPopupPlay => "Играть";
  @override
  String get gametutorialCongratulationsPopupTitle => "Поздравляем!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "Русский: Вы успешно завершили этот урок! Но вы всегда можете начать заново, если еще остались темные участки!";

  @override
  String get gameTutorialPopupTitle => "Помощь";

  @override
  String get gameTutorialProgressPopupNextLesson => "Следующий Урок";
  @override
  String get gameTutorialProgressPopupTitle => "Поздравляем!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Ковриков!";

  @override
  String referralNotificationBody(String name) =>
      "Поздравляем! Вы получили 50 Ковриков благодаря регистрации $name!";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "Мы не видели вас несколько дней. Приходите тренировать свой мозг, играя в игры!";
  @override
  String get notificationMissTitle => "Мы скучаем по вам!";
  @override
  String get notificationGiftBody =>
      "Каждый час вы получаете Коврики бесплатно! Приходите забрать свой подарок!";
  @override
  String get notificationGiftTitle => "Не упустите ваш подарок!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Дождитесь изменения цвета короля, чтобы победить в игре.";
  @override
  String get invalidDeckTitle => "Недействительная колода!";
  @override
  String get invalidDeckDescription =>
      "Ваша текущая колода недействительна. Пожалуйста, исправьте ее или выберите другую перед началом новой игры!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "Не удалось подключиться к вашей игровой учетной записи. Пожалуйста, проверьте ваше интернет-соединение и попробуйте снова!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Ошибка аутентификации!";

  @override
  String get globalRetry => "Повторить";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Требуется аутентификация!";
  @override
  String get authenticationPopupLoadingAuthentication => "Аутентификация!";

  @override
  String authenticationPopupDescription(String account) =>
      "Мы подключим вас к вашей учетной записи $account, чтобы сохранить ваш прогресс в игре!";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Игры";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Колода $index";

  @override
  String get cardOptionButtonDescription =>
      "У вас может быть до 3 колод. Просмотрите и выберите свою игровую колоду здесь.";

  @override
  String get globalValidate => "Подтвердить";

  @override
  String get blockedAccountContactSakiHub => "Свяжитесь с Saki Hub";

  @override
  String get blockedAccountDescription =>
      "Блокировка учетной записи является результатом незаконной или подозрительной деятельности. Если это блокировка - ошибка, свяжитесь с нами!";
  @override
  String get blockedAccountTitle => "Ваша учетная запись заблокирована!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Коврики увеличивают вашу игровую свободу, но для их использования вам нужно быть в сети!";
  @override
  String get progressOptionButtonNotAuthenticatedTitle => "У вас нет Ковриков!";
  @override
  String get progressOptionButtonShowcase =>
      "Коврики, игровая валюта, необходимы для покупки карт и игры. Управляйте своими Ковриками здесь.";

  @override
  String get globalAd => "РЕКЛАМА";

  @override
  String get globalConnect => "Подключить";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Атакующие";
  @override
  String get attackerFamilyShortDescription => "Красные карты: Сильны в атаке";
  @override
  String get attackerFamilyLongDescription =>
      "Эти карты наносят максимальный урон вашим врагам. Однако они не отличаются в других областях!";

  @override
  String get defenderFamilyName => "Защитники";
  @override
  String get defenderFamilyShortDescription => "Серые карты: Сильны в защите";
  @override
  String get defenderFamilyLongDescription =>
      "У этих карт самые высокие значения защиты. Однако они не отличаются в других областях!";

  @override
  String get healerFamilyName => "Лекари";
  @override
  String get healerFamilyShortDescription =>
      "Зеленые карты: Сильны в исцелении";
  @override
  String get healerFamilyLongDescription =>
      "Эти карты лечат ваших союзников лучше всего. Однако они не отличаются в других областях!";

  @override
  String get lordFamilyName => "Лорды";
  @override
  String get lordFamilyShortDescription =>
      "Лорды: Должны быть защищены любой ценой";
  @override
  String get lordFamilyLongDescription =>
      "Это карты, которые должны быть защищены любой ценой в игре: вы проигрываете автоматически, если меняется цвет вашего лорда!";

  @override
  String get normalFamilyName => "Обычные";
  @override
  String get normalFamilyShortDescription =>
      "Коричневые карты: Сбалансированные способности";
  @override
  String get normalFamilyLongDescription =>
      "Обычные карты являются наиболее сбалансированными в игре. Они очень универсальны и действительно предоставляют преимущество на поле боя!";

  @override
  String get specialFamilyName => "Специальные";
  @override
  String get specialFamilyShortDescription =>
      "Желтые карты: Специальные эффекты на другие карты";
  @override
  String get specialFamilyLongDescription =>
      "Эти карты оказывают влияние на другие карты. Их эффекты в основном зависят от их характера!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Урок 1/3: Основы игры";
  @override
  String get globalLesson => "Урок";
  @override
  String get basicsLessonSuffix => "Основы игры";
  @override
  String get basicsLessonWinningMessage =>
      "Поздравляем с победой! Чтобы узнать больше о роли карт в игре, перейдите к следующему уроку!";

  @override
  String get normalLessonTitle => "Урок 2/3: Роль карт";
  @override
  String get normalLessonSuffix => "Роль карт";
  @override
  String get specialLessonSuffix => "Специальные карты";
  @override
  String get normalLessonDescription =>
      "Красные карты атакуют, зеленые поддерживают, желтые защищают, а синие уравнивают!";
  @override
  String get normalLessonWinningMessage =>
      "Поздравляем с победой! Чтобы научиться блокировать тайлы, перейдите к следующему уроку!";

  @override
  String get specialLessonTitle => "Урок 3/3: Специальные карты";
  @override
  String get specialLessonDescription =>
      "У специальных карт есть особые свойства, которые в большей степени зависят от их природных характеристик!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Отлично!";
  @override
  String get congratulationsMessage => "Поздравляем!";
  @override
  String get excellentMessage => "Превосходно!";
  @override
  String get goodMessage => "Хорошо!";
  @override
  String get greatMessage => "Отлично!";
  @override
  String get magnificentMessage => "Великолепно!";
  @override
  String get masterfulMessage => "Мастерски!";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "Чтобы получить карту, перетащите карту на цель, которая находится перед вами!";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Чтобы перейти к зеленой карте, переместите карту на цель, на которой есть зеленая карта, и переместите карту на зеленую карту!";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Чтобы изменить цвет зеленой карты, необходимо иметь соединение и количество очков должно быть равно 0!";
  @override
  String get basicsCutPathInstruction =>
      "Чтобы разорвать соединение между двумя картами, проведите линию как показано в указанном направлении и коснитесь ее!";
  @override
  String get basicsConnectKingInstruction =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";
  String get basicsConquerKingInstruction =>
      "Чтобы изменить цвет карты короля, необходимо иметь соединение и количество очков должно быть равно 0!";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Чтобы получить карту обычного гражданина, перетащите карту на цель, которая находится перед вами!";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "Чтобы подтвердить присутствие обычного гражданина, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get normalPlaceHealerInstruction =>
      "Вашего короля атаковали, и ему срочно нужно лечение! Чтобы использовать карту лечения, перетащите ее на соответствующую цель!";
  @override
  String get normalConnectHealerInstruction =>
      "Ваш король в опасности, и его необходимо срочно спасти, чтобы не поменяли цвет! Для подтверждения спасения переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get normalPlaceAttackerInstruction =>
      "Вы можете начать завоевание. Чтобы получить карту атакующего, перетащите карту на цель, которая находится перед вами!";
  @override
  String get normalConnectAttackerInstruction =>
      "Чтобы завоевать, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get normalConquerAttackerInstruction =>
      "Чтобы изменить цвет карты цели, необходимо иметь соединение и количество очков должно быть равно 0!";
  @override
  String get normalPlaceDefenderInstruction =>
      "Вы можете начать укрепление своих жителей. Чтобы получить карту защитника, перетащите карту на цель, которая находится перед вами!";
  @override
  String get normalConnectDefenderInstruction =>
      "Переместите карту с целью, чтобы укрепить своих жителей и защитить короля!";
  @override
  String get normalConnectKingInstruction =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Вы можете начать завоевание. Чтобы получить карту обычного гражданина, перетащите карту на цель, которая находится перед вами!";
  @override
  String get specialPlaceCompressionInstruction =>
      "Чтобы начать завоевание, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialConnectCompressionInstruction =>
      "Чтобы соединиться с вашей целью, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "Чтобы соединиться с вашей целью, получите карту холодильника с помощью игры!";
  @override
  String get specialConnectRefrigerationInstruction =>
      "Чтобы соединиться с вашей целью, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "Чтобы соединиться с вашей целью, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialPlaceExpansionInstruction =>
      "Вы можете начать завоевание. Чтобы получить карту расширения, перетащите карту на цель, которая находится перед вами!";
  @override
  String get specialConnectExpansionInstruction =>
      "Чтобы начать завоевание, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Чтобы соединиться с вашей целью, переместите карту с целью, выбранной с помощью исходной карты!";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Чтобы изменить цвет карты цели, необходимо иметь соединение и количество очков должно быть равно 0!";
  @override
  String get specialConnectKingInstruction =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "Чтобы поместить карту, перетащите ее на цель и бросьте!";
  @override
  String get basicsConnectCenterTileDescription =>
      "Чтобы соединиться с картой в центре, переместите карту на цель с зеленой картой и бросьте карту на нее!";
  @override
  String get basicsConquerCenterTileDescription =>
      "Чтобы завоевать карту в центре, необходимо соединение и количество очков должно быть равно 0!";
  @override
  String get basicsCutPathDescription =>
      "Чтобы разорвать соединение между двумя картами, проведите линию как показано и коснитесь!";
  @override
  String get basicsConnectKingDescription =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";
  @override
  String get kingConquestDescription =>
      "Чтобы изменить цвет карты короля, необходимо соединение и количество очков должно быть равно 0!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "Чтобы получить карту обычного гражданина, перетащите карту на цель и бросьте!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "Чтобы соединиться с картой обычного гражданина, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get normalPlaceHealerDescription =>
      "Вашего короля атакуют, и ему нужна помощь! Чтобы использовать карту лечения, перетащите ее на нужную цель и бросьте!";
  @override
  String get normalConnectHealerDescription =>
      "Ваш король в опасности, и его нужно спасти, чтобы не сменили цвет! Чтобы сохранить короля, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте!";
  @override
  String get normalPlaceAttackerDescription =>
      "Вы можете начать атаковать. Чтобы получить карту атакующего, перетащите карту на цель и бросьте!";
  @override
  String get normalConnectAttackerDescription =>
      "Чтобы начать атаку, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get normalConquerAttackerDescription =>
      "Чтобы изменить цвет карты цели, необходимо соединение и количество очков должно быть равно 0!";
  @override
  String get normalPlaceDefenderDescription =>
      "Вы можете начать укрепление своих жителей. Чтобы получить карту защитника, перетащите карту на цель и бросьте!";
  @override
  String get normalConnectDefenderDescription =>
      "Чтобы укрепить своих жителей и защитить короля, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get normalConnectKingDescription =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "Вы можете начать атаковать. Чтобы получить карту обычного гражданина, перетащите карту на цель и бросьте!";
  @override
  String get specialPlaceCompressionDescription =>
      "Чтобы начать атаку, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialConnectCompressionDescription =>
      "Чтобы соединиться с картой цели, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "Чтобы соединиться с картой цели, получите карту холодильника, играя!";
  @override
  String get specialConnectRefrigerationDescription =>
      "Чтобы соединиться с картой цели, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "Чтобы соединиться с картой цели, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialPlaceExpansionDescription =>
      "Вы можете начать атаковать. Чтобы получить карту расширения, перетащите карту на цель и бросьте!";
  @override
  String get specialConnectExpansionDescription =>
      "Чтобы начать атаку, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "Чтобы соединиться с картой цели, переместите карту на цель с целью, выбранной с помощью исходной карты и бросьте карту на нее!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "Чтобы изменить цвет карты цели, необходимо соединение и количество очков должно быть равно 0!";
  @override
  String get specialConnectKingDescription =>
      "Вашего короля атакуют. Оставьте его в покое и завершите ход!";

  /* SKILLS */

  @override
  String get attackSkillNull => "Нулевое";
  @override
  String get attackSkillVeryBad => "Очень плохое";
  @override
  String get attackSkillBad => "Плохое";
  @override
  String get attackSkillNormal => "Обычное";
  @override
  String get attackSkillGood => "Хорошее";
  @override
  String get attackSkillVeryGood => "Отличное";

  @override
  String get supportSkillNull => "Нулевое";
  @override
  String get supportSkillVeryBad => "Очень плохое";
  @override
  String get supportSkillBad => "Плохое";
  @override
  String get supportSkillNormal => "Обычное";
  @override
  String get supportSkillGood => "Хорошее";
  @override
  String get supportSkillVeryGood => "Отличное";

  @override
  String get resistanceSkillNull => "Нулевое";
  @override
  String get resistanceSkillVeryBad => "Очень плохое";
  @override
  String get resistanceSkillBad => "Плохое";
  @override
  String get resistanceSkillNormal => "Обычное";
  @override
  String get resistanceSkillGood => "Хорошее";
  @override
  String get resistanceSkillVeryGood => "Отличное";

  @override
  String get lifeSkillNull => "Нулевое";
  @override
  String get lifeSkillHalf => "Половина";
  @override
  String get lifeSkillNormal => "Обычное";

  @override
  String get speedSkillNull => "Нулевое";
  @override
  String get speedSkillHalf => "Половина";
  @override
  String get speedSkillNormal => "Обычное";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "Закрытие этой части обойдется вам ровно в $cowries каури! Вы действительно хотите закрыть игру?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "Закрытие этой части обойдется вам ровно в $cowries каури! Вы действительно хотите закрыть игру?";
  @override
  String get adventureSimpleCloseDescription =>
      "Закрытие текущей игры приведет к потере вашего прогресса! Вы действительно хотите закрыть текущую игру?";
  @override
  String get remoteSimpleCloseDescription =>
      "Закрытие этой части приведет к потере ее текущего прогресса! Вы действительно хотите закрыть эту часть?";
  @override
  String get closeClose => "Закрыть";
  @override
  String get closeTitle => "Закрыть";

  @override
  String get watchAdButtonRefreshAd => "Обновить рекламу";
  @override
  String get cardOptionButtonPopupSelectDeck => "Выбрать эту колоду";

  @override
  String get lessonChangeTitle => "Изменение урока";
  @override
  String get lessonChangeDescription =>
      "Пожалуйста, овладейте материалом этого урока, прежде чем перейти к другому! Вы действительно хотите изменить урок?";
  @override
  String get lessonChangeAction => "Изменить";

  @override
  String get restoreDefaultLanguage => "Восстановить язык по умолчанию";

  //

  @override
  String get loadingDescription =>
      "Мы загружаем данные игры. Пожалуйста, подождите немного!";
  @override
  String get homeUpdateSimpleDescription =>
      "Доступна новая версия игры. Установите ее быстро, чтобы насладиться последними новинками!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "Теперь вы можете погрузиться в мир игры и исследовать все ее тонкости!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "Я искусственный интеллект $level уровня игры! Я сделаю все возможное, чтобы предложить вам отличную партию!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "Я искусственный интеллект обучающего курса игры. Просто следуйте инструкциям, чтобы победить!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "Транзакция отменена!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "Мы не смогли подтвердить вашу покупку. Пожалуйста, проверьте ваш метод оплаты и интернет-соединение!";

  @override
  String get drawTitle => "Ничья!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "Вы завершили матч в ничью! В любом случае, вы уже прошли все уровни этого режима игры!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "Вы завершили матч в ничью! В любом случае, вы уже прошли этот уровень и можете перейти к следующему!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "Вы завершили матч в ничью! Вы можете попробовать снова и победить в следующей игре против ИИ!";
  @override
  String get remoteDrawDescription =>
      "Вы не выиграли и не проиграли! Почему бы не начать новую игру с другим игроком, чтобы определить победителя?";
  @override
  String get newPlayer => "Новый игрок";

  @override
  String get premiumButtonRemoveAds => "Убрать рекламу";
}
