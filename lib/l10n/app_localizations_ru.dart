// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Объявления';

  @override
  String get favorites => 'Избранное';

  @override
  String get add_to_favorites => 'Добавить в избранное';

  @override
  String get added_to_favorites => 'Добавлено в избранное';

  @override
  String get removed_from_favorites => 'Удалено из избранного';

  @override
  String get remove_from_favorites => 'Удалить из избранного';

  @override
  String get edit => 'Редактировать';

  @override
  String get share => 'Поделиться';

  @override
  String get complain => 'Пожаловаться';

  @override
  String get sign_in => 'Войти';

  @override
  String get location => 'Район';

  @override
  String get create_listing => 'Создать';

  @override
  String get profile => 'Профиль';

  @override
  String get role_tenant => 'Арендатор';

  @override
  String get role_landlord => 'Арендодатель';

  @override
  String get role_manager => 'Менеджер';

  @override
  String get role_moderator => 'Модератор';

  @override
  String get role_admin => 'Администратор';

  @override
  String get role_service_provider => 'Исполнитель услуг';

  @override
  String get role_service_requester => 'Заказчик услуг';

  @override
  String get profile_completion => 'Заполнение профиля';

  @override
  String get profile_completion_hint =>
      'Заполненный профиль = более точные совпадения и комфортное соседство.';

  @override
  String get complete_profile_prompt_title => 'Заполните профиль';

  @override
  String get complete_profile_prompt_body =>
      'Укажите предпочтения по образу жизни, чтобы получить лучшие совпадения.';

  @override
  String complete_profile_prompt_more(String count) {
    return '+ ещё $count';
  }

  @override
  String get complete_profile_prompt_cta => 'Заполнить сейчас';

  @override
  String get complete_profile_prompt_later => 'Позже';

  @override
  String get group_join_requires_profile =>
      'Заполните профиль, чтобы вступить в эту группу.';

  @override
  String get compatibility_title => 'Совместимость с вами:';

  @override
  String compatibility_match_percentage(String percent) {
    return 'Совпадение: $percent%';
  }

  @override
  String get compatibility_match_placeholder => 'Совпадение: —';

  @override
  String get compatibility_calculating => 'Считаем совпадение...';

  @override
  String get compatibility_sign_in => 'Войдите, чтобы увидеть совместимость';

  @override
  String get na => 'Н/Д';

  @override
  String get compatibility_matches => 'Совпадающие предпочтения:';

  @override
  String get compatibility_differences => 'Возможные различия:';

  @override
  String get compatibility_critical_differences => 'Критичные различия:';

  @override
  String compatibility_based_on_preferences(String scored, String total) {
    return 'На основе $scored из $total предпочтений';
  }

  @override
  String get vs => 'vs';

  @override
  String get name => 'Имя или никнейм';

  @override
  String get im_from => 'Я из:';

  @override
  String get welcome => 'Привет';

  @override
  String get user => 'Пользователь';

  @override
  String get welcome_title => 'Добро пожаловать в UyDosh';

  @override
  String get welcome_subtitle => 'Найди идеального соседа или жильё';

  @override
  String get splash_subtitle => 'ДАВАЙТЕ ЖИТЬ ВМЕСТЕ!';

  @override
  String get search_results => 'Результаты поиска';

  @override
  String get close => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get about_uy_dosh => 'Об UyDosh';

  @override
  String get privacy_policy_title => 'Политика конфиденциальности';

  @override
  String get privacy_policy_body =>
      'Политика конфиденциальности доступна по ссылке:\nhttps://uydoshtech.github.io/privacy-policy.html';

  @override
  String get user_license_agreement_title =>
      'Лицензионное соглашение пользователя';

  @override
  String get loading => 'Загрузка';

  @override
  String get loading_listings => 'Загрузка объявлений...';

  @override
  String get loading_listing_details => 'Загрузка деталей объявления...';

  @override
  String get loading_universities => 'Загрузка университетов...';

  @override
  String get loading_regions => 'Загрузка районов...';

  @override
  String get loading_map => 'Загрузка карты...';

  @override
  String get map_web_preview => 'Веб-предпросмотр';

  @override
  String metro_station_walk_area_label(int minutes) {
    return '$minutes мин пешком';
  }

  @override
  String map_walk_radius_button_label(int minutes) {
    return '$minutes мин';
  }

  @override
  String map_walk_radius_button_tooltip(int minutes) {
    return 'Радиус ходьбы: $minutes мин';
  }

  @override
  String get open_map_view => 'Открыть карту';

  @override
  String get open_feed_view => 'Открыть ленту';

  @override
  String get choose_filters => 'Пожалуйста, выберите фильтр';

  @override
  String get map_location_prompt_title => 'Показать мою геопозицию';

  @override
  String get map_location_prompt_action => 'Использовать геопозицию';

  @override
  String get map_update_my_location => 'Обновить мою геопозицию';

  @override
  String get permission_location_title => 'Смотреть объявления на карте';

  @override
  String get permission_location_body =>
      'Разрешите геопозицию, чтобы UyDosh мог открыть карту и показать, где вы находитесь относительно объявлений рядом.';

  @override
  String get permission_location_cta => 'Разрешить геопозицию';

  @override
  String get permission_location_denied_body =>
      'Доступ к геопозиции отключён в настройках. Откройте настройки, чтобы включить карту.';

  @override
  String get show_district_layer => 'Показать слой районов';

  @override
  String get hide_district_layer => 'Скрыть слой районов';

  @override
  String get show_metro_stations_layer => 'Показать станции метро';

  @override
  String get hide_metro_stations_layer => 'Скрыть станции метро';

  @override
  String get metro_layer_select_line => 'Выбрать линию метро';

  @override
  String get metro_layer_off => 'Без станций метро';

  @override
  String get metro_layer_all_stations => 'Все станции метро';

  @override
  String get metro_line_1 => 'Линия 1';

  @override
  String get metro_line_2 => 'Линия 2';

  @override
  String get metro_line_3 => 'Линия 3';

  @override
  String get metro_line_4 => 'Линия 4';

  @override
  String get show_universities_layer => 'Показать университеты';

  @override
  String get hide_universities_layer => 'Скрыть университеты';

  @override
  String get switch_to_dark_map => 'Переключить карту на тёмную';

  @override
  String get switch_to_light_map => 'Переключить карту на светлую';

  @override
  String get show_grocery_stores_layer => 'Показать продуктовые магазины';

  @override
  String get hide_grocery_stores_layer => 'Скрыть продуктовые магазины';

  @override
  String get show_bus_stops_layer => 'Показать автобусные остановки';

  @override
  String get hide_bus_stops_layer => 'Скрыть автобусные остановки';

  @override
  String get error => 'Ошибка';

  @override
  String get error_loading_listing_details =>
      'Ошибка загрузки деталей объявления';

  @override
  String get error_listing_not_loaded => 'Объявление еще не загружено';

  @override
  String get error_listing_still_loading => 'Объявление все еще загружается';

  @override
  String get error_sharing_listing =>
      'Не удалось поделиться объявлением. Попробуйте еще раз.';

  @override
  String get error_loading_profile => 'Не удалось загрузить профиль';

  @override
  String get error_internet_connection => 'Проверьте подключение к интернету';

  @override
  String get error_resource_conflict =>
      'Вы уже пожаловались на это объявление.';

  @override
  String get conversations => 'Сообщения';

  @override
  String get messages => 'Сообщения';

  @override
  String get chat => 'Чат';

  @override
  String chat_with(String name) {
    return 'Чат с $name';
  }

  @override
  String get profile_interlocutor => 'Профиль собеседника';

  @override
  String get view_listing => 'Посмотреть объявление';

  @override
  String get view_group => 'Посмотреть группу';

  @override
  String get menu_messages => 'Сообщения';

  @override
  String get notifications_alerts_explainer =>
      'Здесь ваши оповещения.\nКак только появится подходящее жильё или сосед — мы пришлём push-уведомление.';

  @override
  String get notifications_alerts_explainer_enabled =>
      'Уведомления включены.\n\nЗдесь ваши оповещения. Как только появится подходящее жильё или сосед — мы пришлём push-уведомление.';

  @override
  String get notifications_open_settings => 'Открыть настройки';

  @override
  String get type_message => 'Введите сообщение...';

  @override
  String get conversation_created => 'Разговор начат';

  @override
  String get conversation_failed => 'Не удалось начать разговор';

  @override
  String get no_conversations => 'Пока нет разговоров';

  @override
  String get no_messages => 'Пока нет сообщений';

  @override
  String get no_messages_description =>
      'Вы еще не получили сообщений о ваших объявлениях';

  @override
  String get error_not_authenticated =>
      'Войдите в систему, чтобы начать разговор';

  @override
  String get error_cannot_message_self => 'Вы не можете писать сообщения себе';

  @override
  String get start_conversation_from_listing =>
      'Начните разговор с объявления, чтобы начать общение';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчера';

  @override
  String in_days(String days) {
    return 'Через $days дней';
  }

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get now => 'сейчас';

  @override
  String get send_first_message =>
      'Отправьте первое сообщение, чтобы начать разговор';

  @override
  String get opening_existing_conversation =>
      'Открытие существующего разговора';

  @override
  String get chat_security_ribbon_title => 'Советы по безопасности';

  @override
  String get chat_security_ribbon_body =>
      'Общайтесь в UyDosh. Не переводите предоплату и не сообщайте коды подтверждения до личной встречи и проверки деталей.';

  @override
  String get chat_safety_warning_title_high => 'Будьте осторожны';

  @override
  String get chat_safety_warning_title_medium => 'Будьте внимательны';

  @override
  String get chat_safety_warning_fallback =>
      'Этот разговор может быть рискованным. Избегайте предоплаты и держите общение на платформе.';

  @override
  String get chat_safety_reason_deposit_to_reserve_room =>
      'Собеседник просит депозит, чтобы «забронировать» комнату.';

  @override
  String get chat_safety_reason_suspicious_link =>
      'Собеседник отправляет подозрительную ссылку.';

  @override
  String get chat_safety_reason_off_platform =>
      'Собеседник пытается перевести общение вне платформы.';

  @override
  String get chat_safety_reason_otp_code =>
      'Собеседник просит код подтверждения (OTP/SMS).';

  @override
  String get chat_safety_reason_payment_request =>
      'Собеседник просит предоплату или платежные данные.';

  @override
  String get quick_question_room_available => 'Комната свободна?';

  @override
  String get quick_question_move_in_date => 'Когда можно въехать?';

  @override
  String get any_date => 'Любая дата';

  @override
  String get quick_question_people_living =>
      'Сколько людей уже живет в квартире?';

  @override
  String get quick_question_total_price =>
      'Какая итоговая цена со всеми коммунальными?';

  @override
  String get quick_question_can_visit_soon =>
      'Можно прийти посмотреть на днях?';

  @override
  String get quick_question_roommate_still_searching =>
      'Вы ещё ищете сожителя?';

  @override
  String get quick_question_roommate_move_in_date =>
      'Когда можно было бы заселиться?';

  @override
  String get quick_question_roommate_household => 'Кто уже живёт в квартире?';

  @override
  String get quick_question_roommate_rent_terms =>
      'Как делите аренду и коммунальные?';

  @override
  String get quick_question_roommate_meet_soon =>
      'Можем познакомиться или созвониться?';

  @override
  String get quick_question_seeker_move_in_when => 'Когда планируете заехать?';

  @override
  String get quick_question_seeker_budget => 'Какой у вас бюджет?';

  @override
  String get quick_question_seeker_how_long => 'На какой срок ищете?';

  @override
  String get quick_question_seeker_about_you => 'Расскажете немного о себе?';

  @override
  String get quick_question_generic_price => 'Сколько стоит?';

  @override
  String get quick_question_generic_whats_included => 'Что входит в стоимость?';

  @override
  String get quick_question_generic_when_available => 'Когда вы свободны?';

  @override
  String get quick_question_generic_how_soon => 'Как быстро можно начать?';

  @override
  String get quick_question_generic_arrangement => 'Как удобнее организовать?';

  @override
  String get quick_question_generic_clarify_details => 'Можно уточнить детали?';

  @override
  String get quick_question_offerer_scope => 'Что именно нужно сделать?';

  @override
  String get quick_question_offerer_deadline => 'К какому сроку это нужно?';

  @override
  String get quick_question_offerer_where => 'Где это будет происходить?';

  @override
  String get quick_question_offerer_budget => 'Какой бюджет вы закладываете?';

  @override
  String get quick_question_offerer_materials =>
      'Материалы предоставите вы или мне брать с собой?';

  @override
  String get quick_question_offerer_visit =>
      'Можем договориться о коротком звонке или выезде для оценки?';

  @override
  String get private_room => 'Отдельная комната';

  @override
  String get private_room_only => 'Отдельная комната';

  @override
  String get with_photo => 'С фото';

  @override
  String get search_filter_private_room => 'Отдельная комната';

  @override
  String get search_filter_with_photo => 'С фото';

  @override
  String get conversation_count => 'разговор';

  @override
  String get conversations_count => 'разговора';

  @override
  String get incoming => 'Входящие';

  @override
  String get outgoing => 'Исходящие';

  @override
  String get no_incoming_conversations => 'Нет входящих разговоров';

  @override
  String get no_outgoing_conversations => 'Нет исходящих разговоров';

  @override
  String get no_incoming_conversations_description =>
      'Вы еще не получили сообщений о ваших объявлениях';

  @override
  String get retry => 'Повторить';

  @override
  String get back_to_listing => 'Вернуться к объявлению';

  @override
  String get load_more => 'Загрузить еще';

  @override
  String get error_generic => 'Произошла ошибка';

  @override
  String error_loading_regions(String error) {
    return 'Ошибка загрузки районов: $error';
  }

  @override
  String error_loading_universities(String error) {
    return 'Ошибка загрузки университетов: $error';
  }

  @override
  String get error_creating_listing =>
      'Ошибка создания объявления. Попробуйте еще раз.';

  @override
  String get error_updating_listing => 'Ошибка при обновлении объявления';

  @override
  String get error_uploading_photos => 'Ошибка загрузки фотографий';

  @override
  String get error_deactivating_listing => 'Ошибка деактивации объявления';

  @override
  String error_creating_profile(String error) {
    return 'Ошибка создания профиля. Попробуйте еще раз.';
  }

  @override
  String error_updating_profile(String error) {
    return 'Ошибка обновления профиля: $error';
  }

  @override
  String error_opening_edit_screen(String error) {
    return 'Ошибка открытия экрана редактирования: $error';
  }

  @override
  String error_with_message(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get image_load_error => 'Не удалось загрузить изображение';

  @override
  String get listing_created_success => 'Объявление успешно создано!';

  @override
  String get room_scan_title => '3D-скан комнаты';

  @override
  String get room_scan_instructions =>
      'Отсканируйте комнату с помощью LiDAR (iPhone Pro или совместимый iPad). После завершения модель загрузится в объявление.';

  @override
  String get room_scan_start => 'Начать сканирование';

  @override
  String get room_scan_uploading => 'Загрузка…';

  @override
  String get room_scan_success => '3D-скан сохранён';

  @override
  String get room_scan_cancelled =>
      'Скан не был сделан. Нажмите «Начать», чтобы попробовать снова.';

  @override
  String get room_scan_error => 'Не удалось сохранить скан. Попробуйте снова.';

  @override
  String get room_scan_not_supported =>
      '3D-скан требует iPhone или iPad с LiDAR.';

  @override
  String get room_scan_disabled_globally =>
      '3D-сканирование комнаты отключено в настройках приложения. Позже оно может снова стать доступным.';

  @override
  String get add_room_scan_3d => 'Добавить 3D-скан комнаты';

  @override
  String get replace_room_scan_3d => 'Заменить 3D-скан комнаты';

  @override
  String get room_scan_examples_label => 'Примеры сканов';

  @override
  String get skip => 'Пропустить';

  @override
  String get listing_updated_success => 'Объявление успешно обновлено';

  @override
  String get profile_completed_success => 'Профиль успешно завершен!';

  @override
  String get profile_updated_success => 'Профиль успешно обновлен';

  @override
  String get favorite_added_success => 'Добавлено в избранное';

  @override
  String get favorite_removed_success => 'Удалено из избранного';

  @override
  String get successfully_signed_in_google => 'Успешный вход через Google!';

  @override
  String get no_listings_found => 'Объявления не найдены';

  @override
  String get my_listings_empty_state =>
      'Вы еще не создали ни одного объявления.';

  @override
  String get no_locations_available => 'Районы недоступны';

  @override
  String get no_universities_available => 'Университеты недоступны';

  @override
  String get no_search_results => 'Нет результатов...';

  @override
  String get try_refreshing => 'Попробуйте обновить или проверьте позже';

  @override
  String get try_refining_search => 'Попробуйте уточнить критерии поиска';

  @override
  String get refine_search => 'Уточнить поиск';

  @override
  String get select_metro_line => 'Линия метро';

  @override
  String get select_metro_line_title => 'Выберите\nлинию метро';

  @override
  String get metro_line_abbr => 'лн.';

  @override
  String get metro_station_abbr => 'ст.';

  @override
  String get select_location => 'Любой район';

  @override
  String get not_selected => 'Не выбрано';

  @override
  String all_stations_count(String count) {
    return 'Все $count станций';
  }

  @override
  String all_stations_explanation(String line, String count) {
    return 'Поиск по всем <b>$count</b> станциям линии <b>$line</b>';
  }

  @override
  String entire_line_stations(String line, String count) {
    return 'Вся линия $line: $count станций';
  }

  @override
  String get metro_tutorial_search_hint =>
      'Поиск по линии метро или по отдельным станциям.';

  @override
  String get metro_tutorial_line_hint =>
      'Поиск объявлений на всех станциях линий метро';

  @override
  String get metro_tutorial_station_hint =>
      'Поиск по конкретным станциям метро';

  @override
  String get metro_tutorial_tap_to_continue => 'Нажмите, чтобы продолжить';

  @override
  String get select_region => 'Выберите область';

  @override
  String get select_region_profile_creation_title => 'Откуда вы?';

  @override
  String get select_region_profile_creation_description =>
      'Мы поможем вам найти людей из вашего родного города.';

  @override
  String get select_university => 'Выберите университет';

  @override
  String get select_language => 'Выбрать язык';

  @override
  String get select_theme => 'Выбрать тему';

  @override
  String get select_theme_description =>
      'Выберите предпочитаемую тему приложения';

  @override
  String get please_complete_previous_steps =>
      'Пожалуйста, сначала завершите предыдущие шаги';

  @override
  String get please_complete_all_fields => 'Пожалуйста, заполните все поля';

  @override
  String get please_select_university => 'Пожалуйста, выберите университет';

  @override
  String get tap_to_select_region => 'Нажмите, чтобы выбрать район';

  @override
  String get no_regions_available => 'Районов недоступно';

  @override
  String get refresh => 'Обновить';

  @override
  String get actions => 'Действия';

  @override
  String get view_profile => 'Профиль';

  @override
  String get deactivate_listing => 'Деактивировать';

  @override
  String get deactivate_listing_confirmation =>
      'Вы уверены, что хотите деактивировать это объявление? Оно больше не будет видно другим пользователям.';

  @override
  String get deactivate => 'Деактивировать';

  @override
  String get activate_listing => 'Активировать объявление';

  @override
  String get activate_listing_confirmation =>
      'Вы уверены, что хотите активировать это объявление? Оно станет видно другим пользователям.';

  @override
  String get activate => 'Активировать';

  @override
  String get listing_active => 'Активно';

  @override
  String get listing_inactive => 'Неактивно';

  @override
  String get create_listing_button => 'Создать объявление';

  @override
  String get update_listing_button => 'Обновить объявление';

  @override
  String get save_changes => 'Сохранить изменения';

  @override
  String get unsaved_changes_title => 'Несохранённые изменения';

  @override
  String get unsaved_changes_message =>
      'У вас есть несохранённые изменения. Если выйти сейчас, они будут потеряны.';

  @override
  String get keep_editing => 'Продолжить';

  @override
  String get leave_without_saving => 'Выйти';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get apply => 'Применить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get complete => 'Завершить';

  @override
  String get settings => 'Настройки';

  @override
  String get settings_section_account => 'Аккаунт';

  @override
  String get settings_section_preferences => 'Предпочтения';

  @override
  String get settings_section_experience => 'Удобства';

  @override
  String get settings_section_map => 'Настройки карты';

  @override
  String get settings_section_about => 'О приложении';

  @override
  String get settings_section_legal => 'Правовая информация';

  @override
  String get theme => 'Тема';

  @override
  String get blue_theme => 'Синяя';

  @override
  String get light_theme => 'Светлая';

  @override
  String theme_changed_to(String theme) {
    return 'Тема изменена на $theme';
  }

  @override
  String get theme_color => 'Цвет темы';

  @override
  String get switch_theme => 'Переключить тему';

  @override
  String get about_description =>
      'UyDosh — маркетплейс аренды и поиска соседей в Узбекистане: ищите, общайтесь и заселяйтесь уверенно.';

  @override
  String get about_feature_1 => 'Умный поиск по метро, районам и фильтрам';

  @override
  String get about_feature_2 => 'Чат с владельцами и соседями в приложении';

  @override
  String get about_feature_3 => 'Уведомления о новых подходящих объявлениях';

  @override
  String get about_feature_4 =>
      'Проверенные объявления и безопасное сообщество';

  @override
  String get location_on_map => 'Локация';

  @override
  String get show_map => 'Показать карту';

  @override
  String get tap_to_load_map => 'Нажмите для загрузки';

  @override
  String get hide_map => 'Скрыть карту';

  @override
  String get open_in_yandex_maps => 'Открыть в Яндекс Картах';

  @override
  String get open_in_yandex_maps_confirmation =>
      'Браузер с Яндекс Картами будет открыт.';

  @override
  String get listing_details => 'Детали';

  @override
  String listing_detail_id(String id) {
    return 'ID объявления: $id';
  }

  @override
  String get author => 'Автор';

  @override
  String get show_details => 'Показать детали';

  @override
  String get hide_details => 'Скрыть детали';

  @override
  String listing_views_by_others(String count) {
    return '$count просмотров';
  }

  @override
  String get listing_views_stats_title => 'Статистика просмотров';

  @override
  String get listing_views_stats_empty => 'Пока нет просмотров';

  @override
  String get error_loading_view_stats =>
      'Ошибка загрузки статистики просмотров';

  @override
  String get promote_listing => 'Поднять в топ';

  @override
  String get remove_from_top => 'Убрать с верха';

  @override
  String get feature_listing_success => 'Объявление поднято вверх';

  @override
  String get unfeature_listing_success => 'Объявление убрано с верха';

  @override
  String get feature_listing_error => 'Не удалось обновить объявление';

  @override
  String get error_promotion_once_per_week =>
      'Вы можете поднять объявление только раз в неделю';

  @override
  String get listing_title_hint => 'Введите заголовок объявления';

  @override
  String get listing_description_hint => 'Введите описание объявления';

  @override
  String get listing_price_label => 'Цена';

  @override
  String get listing_area_price_heading => 'Ориентир по цене';

  @override
  String listing_area_price_station_line(String place, String median) {
    return 'У станции «$place»: медиана $median';
  }

  @override
  String listing_area_price_location_line(String place, String median) {
    return 'В районе «$place»: медиана $median';
  }

  @override
  String get listing_area_price_insufficient_data =>
      'Пока недостаточно похожих объявлений, чтобы показать ориентир по цене.';

  @override
  String get listing_area_price_unknown_station => 'Эта станция метро';

  @override
  String get listing_area_price_unknown_district => 'Этот район';

  @override
  String get listing_translate_tooltip_en => 'Перевести на английский';

  @override
  String get listing_translate_tooltip_ru => 'Перевести на русский';

  @override
  String get listing_translate_tooltip_uz => 'Перевести на узбекский';

  @override
  String get listing_show_original_description => 'Оригинал';

  @override
  String get listing_translating_description => 'Перевод…';

  @override
  String get listing_translation_error =>
      'Не удалось перевести. Попробуйте снова.';

  @override
  String get listing_translation_unavailable => 'Перевод недоступен.';

  @override
  String get chat_translated_from_en => 'Переведено с 🇺🇸';

  @override
  String get chat_translated_from_ru => 'Переведено с 🇷🇺';

  @override
  String get chat_translated_from_uz => 'Переведено с 🇺🇿';

  @override
  String get chat_show_original => 'Показать оригинал';

  @override
  String get chat_show_translation => 'Показать перевод';

  @override
  String get chat_edit_message_title => 'Редактировать сообщение';

  @override
  String get chat_edit_message_save => 'Сохранить';

  @override
  String get chat_edit_message_cancel => 'Отмена';

  @override
  String get chat_edit_message_once_only =>
      'Вы уже использовали единственное редактирование для этого сообщения.';

  @override
  String get chat_edit_hold_already_edited_toast =>
      'Каждое сообщение можно изменить только один раз — вы уже сохранили правку.';

  @override
  String get chat_message_edited_label => 'Изменено';

  @override
  String get chat_last_message_sender_you => 'Вы';

  @override
  String get view_similar_results => 'Похожие объявления';

  @override
  String get listing_detail_nearby_room_offers => 'Найти жилье';

  @override
  String get listing_detail_nearby_room_seekers => 'Ищут жильё рядом';

  @override
  String get listing_detail_nearby_matches => 'Подходящие рядом';

  @override
  String get coming_soon => 'Скоро будет';

  @override
  String get listing_ai_enhance => 'Улучшить с AI';

  @override
  String get listing_ai_enhance_empty => 'Сначала введите описание.';

  @override
  String get listing_ai_enhance_unavailable => 'Улучшение с AI недоступно.';

  @override
  String get listing_ai_enhance_error =>
      'Не удалось улучшить текст. Попробуйте снова.';

  @override
  String get listing_description_template_label => 'Шаблон';

  @override
  String get listing_description_template_room_needed =>
      'Ищу комнату/подселение.\nФормат: (отдельная/подселение).\nСрок: (заезд + на сколько).\nВажно: (тихо/гости/животные).';

  @override
  String get listing_description_template_roommate_needed_male =>
      'Ищу соседа.\nФормат: (1–2 в комнате).\nКто уже живёт: (сколько человек).\nУсловия: (с хозяйкой/без), (отдельная/общая комната).\nСрок: (заезд) + (на сколько).';

  @override
  String get listing_description_template_roommate_needed_female =>
      'Ищу соседку.\nФормат: (1–2 в комнате).\nКто уже живёт: (сколько человек).\nУсловия: (с хозяйкой/без), (отдельная/общая комната).\nСрок: (заезд) + (на сколько).';

  @override
  String get listing_description_template_group_forming =>
      'Собираем группу для совместной аренды.\nКого ищем: (1–2 человека, пол/возраст).\nБюджет на человека: (сумма).\nРайон/метро: (где ищем).\nФормат: (отдельные/общие комнаты).\nЗаезд: (дата + срок).\nВажно: (чистота/тишина/гости/животные).';

  @override
  String get listing_type_roommate_needed => 'Ищу соседа';

  @override
  String get listing_type_roommate_needed_female => 'Ищу соседку';

  @override
  String get listing_type_room_needed => 'Ищу жилье';

  @override
  String get title_male_roommate => '#ИщемСоседа';

  @override
  String get title_female_roommate => '#ИщемСоседку';

  @override
  String get title_male_room => '#ИщуКомнату';

  @override
  String get title_female_room => '#ИщуКомнату';

  @override
  String get listing_photos_label => 'Фотографии';

  @override
  String listing_photos_count(int current, int max) {
    return 'Фото $current / $max';
  }

  @override
  String get delete_photo => 'Удалить фото';

  @override
  String get delete_photo_confirmation =>
      'Вы уверены, что хотите удалить это фото?';

  @override
  String get photo_deleted_success => 'Фото успешно удалено';

  @override
  String get error_deleting_photo =>
      'Ошибка удаления фото. Попробуйте еще раз.';

  @override
  String get photo_made_primary => 'Фото установлено как основное';

  @override
  String get new_primary_photo_selected =>
      'Новое основное фото автоматически выбрано';

  @override
  String get last_photo_deleted =>
      'Последнее фото удалено - больше нет фотографий';

  @override
  String get cannot_delete_last_photo => 'Невозможно удалить последнее фото';

  @override
  String get tap_photo_to_make_primary =>
      'Нажмите на фото, чтобы сделать его основным';

  @override
  String get making_primary => 'Создание основного...';

  @override
  String get add_photo => 'Добавить фото';

  @override
  String get take_photo => 'Сделать фото';

  @override
  String get choose_from_gallery => 'Выбрать из галереи';

  @override
  String photo_limit_reached(int max) {
    return 'Максимум $max фотографий';
  }

  @override
  String get max_photos_reached => 'Достигнут максимум фотографий';

  @override
  String max_photos_message(int max) {
    return 'Вы можете загрузить максимум $max фото.';
  }

  @override
  String get ok => 'ОК';

  @override
  String get delete => 'Удалить';

  @override
  String get onboarding_title_1 => 'Найди своих';

  @override
  String get onboarding_subtitle_1 =>
      'Проверенные соседи, честные объявления\nи совместная аренда без лишних людей.';

  @override
  String get onboarding_title_2 => 'Ищи там, где удобно жить';

  @override
  String get onboarding_subtitle_2 =>
      'Выбирай метро, район или вуз —\nмы покажем подходящие квартиры и соседей рядом.';

  @override
  String get onboarding_title_3 => 'Поиск по району';

  @override
  String get onboarding_subtitle_3 => 'Удобный поиск по районам Ташкента';

  @override
  String get onboarding_title_4 => 'Без риэлторов и чужих';

  @override
  String get onboarding_subtitle_4 =>
      'Мы строим честное комьюнити:\nпроверенные профили, жалобы и защита от мошенников.';

  @override
  String get onboarding_get_started => 'Начать';

  @override
  String get onboarding_skip => 'Пропустить';

  @override
  String get onboarding_next => 'Далее';

  @override
  String get onboarding_back => 'Назад';

  @override
  String get onboarding_toggle => 'Обучение';

  @override
  String get onboarding_toggle_description => 'Показать приветствие';

  @override
  String get haptic_feedback => 'Виброотклик';

  @override
  String get haptic_feedback_description => 'Вибрация при нажатиях и жестах';

  @override
  String get ui_animations_optimized_for_device =>
      'Оптимизировано для этого устройства';

  @override
  String get current_language => 'Русский';

  @override
  String get language => 'Язык';

  @override
  String get language_english => 'English';

  @override
  String get language_russian => 'Русский';

  @override
  String get language_uzbek => 'O\'zbekcha';

  @override
  String get language_name_english => 'Английский';

  @override
  String get language_name_russian => 'Русский';

  @override
  String get language_name_uzbek => 'Узбекский';

  @override
  String language_changed_to(String language) {
    return 'Язык изменен на $language';
  }

  @override
  String get gender => 'Пол';

  @override
  String get male => 'Парень';

  @override
  String get female => 'Девушка';

  @override
  String get other => 'Другой';

  @override
  String get university => 'Университет';

  @override
  String get same_university => 'Один университет';

  @override
  String get both_students => 'Оба студента';

  @override
  String get region => 'Область';

  @override
  String get same_region => 'Один регион';

  @override
  String get rating => 'Рейтинг';

  @override
  String get about_me => 'Обо мне';

  @override
  String get telegram => 'Telegram';

  @override
  String get open_in_telegram => 'Telegram';

  @override
  String get open_in_telegram_confirmation =>
      'Telegram откроется в приложении или браузере.';

  @override
  String get could_not_open_telegram => 'Не удалось открыть Telegram';

  @override
  String get could_not_make_call => 'Не удалось начать звонок';

  @override
  String get work => 'Работа';

  @override
  String get employed => 'Работаю';

  @override
  String get not_employed => 'Не работаю';

  @override
  String get cleanliness => 'Чистоплотность';

  @override
  String get noise_level => 'Уровень шума';

  @override
  String get sociability => 'Общительность';

  @override
  String get guests => 'Гости';

  @override
  String get guests_allowed => 'Гости разрешены';

  @override
  String get guests_permitted => 'Разрешены';

  @override
  String get guests_not_permitted => 'Не разрешены';

  @override
  String get smoking_preference => 'Курение';

  @override
  String get alcohol_preference => 'Алкоголь';

  @override
  String get cooking_habits => 'Готовка';

  @override
  String get pets_preference => 'Отношение к животным';

  @override
  String get wakeup_time => 'Время подъема';

  @override
  String get sleep_time => 'Время сна';

  @override
  String get non_smoker => 'Не курю';

  @override
  String get occasional_smoker => 'Курю иногда';

  @override
  String get regular_smoker => 'Курю регулярно';

  @override
  String get non_drinker => 'Не пью';

  @override
  String get occasional_drinker => 'Пью иногда';

  @override
  String get regular_drinker => 'Пью регулярно';

  @override
  String get morning => 'Утро';

  @override
  String get evening => 'Вечер';

  @override
  String get night => 'Ночь';

  @override
  String get pets_okay => 'Нормальное';

  @override
  String get pets_not_okay => 'Не очень';

  @override
  String get pets_like_pets => 'Люблю животных';

  @override
  String get pets_dont_like_pets => 'Не люблю животных';

  @override
  String get pets_have_cat => 'Есть кот';

  @override
  String get pets_have_dog => 'Есть собака';

  @override
  String get lifestyle_preferences => 'Образ жизни';

  @override
  String get very_messy => 'Грязный';

  @override
  String get messy => 'Неопрятный';

  @override
  String get average => 'Средне';

  @override
  String get clean => 'Чистоплотный';

  @override
  String get very_clean => 'Очень чистоплотный';

  @override
  String get very_quiet => 'Очень тихий';

  @override
  String get quiet => 'Тихий';

  @override
  String get loud => 'Громкий';

  @override
  String get very_loud => 'Очень шумный';

  @override
  String get very_introverted => 'Необщительный';

  @override
  String get introverted => 'Интроверт';

  @override
  String get balanced => 'Средне';

  @override
  String get extroverted => 'Экстраверт';

  @override
  String get very_extroverted => 'Очень общительный';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get cook => 'Готовлю дома';

  @override
  String get dont_cook => 'Не готовлю';

  @override
  String get not_specified => 'Не указано';

  @override
  String get complete_profile => 'Завершите профиль';

  @override
  String get complete_profile_subheader =>
      'Мы используем эту информацию, чтобы подобрать идеальных соседей и совпадения для вас.';

  @override
  String get full_name => 'Имя или никнейм';

  @override
  String get are_you_student => 'Вы студент?';

  @override
  String get yes_student => 'Студент';

  @override
  String get no_student => 'Не студент';

  @override
  String get are_you_landlord_or_renter => 'Вы арендодатель или арендатор?';

  @override
  String get select_your_primary_role => 'Основная роль';

  @override
  String get tap_to_select_primary_role => 'Выберите роль';

  @override
  String get selected => 'Выбрано';

  @override
  String get full_name_hint => 'Введите ваше имя или никнейм';

  @override
  String get name_required => 'Имя или никнейм обязательно';

  @override
  String get saving => 'Сохранение...';

  @override
  String get firebase_user_not_found => 'Пользователь Firebase не найден';

  @override
  String get user_blocked_violation_title => 'Аккаунт ограничен';

  @override
  String get user_blocked_violation_message =>
      'Ваш аккаунт ограничен из-за нарушения. Вы можете просматривать приложение, но не можете публиковать объявления, отправлять сообщения или редактировать контент. Свяжитесь с поддержкой, если у вас есть вопросы.';

  @override
  String get profile_not_loaded_yet => 'Профиль еще не загружен';

  @override
  String get profile_still_loading => 'Профиль все еще загружается';

  @override
  String get welcome_back_profile_exists =>
      'Добро пожаловать обратно! Профиль уже существует.';

  @override
  String get tap_to_select_university => 'Нажмите, чтобы выбрать университет';

  @override
  String get menu_profile => 'Профиль';

  @override
  String get menu_home => 'Объявления';

  @override
  String get menu_language => 'Язык';

  @override
  String get menu_favorites => 'Избранное';

  @override
  String get menu_history => 'История';

  @override
  String get menu_contact_support => 'Связаться с поддержкой';

  @override
  String get menu_add_listing => 'Добавить объявление';

  @override
  String get menu_my_listings => 'Мои объявления';

  @override
  String get menu_about => 'О приложении';

  @override
  String get menu_privacy_policy => 'Политика конфиденциальности';

  @override
  String get menu_user_license_agreement =>
      'Лицензионное соглашение пользователя';

  @override
  String get menu_faq => 'Вопросы и ответы';

  @override
  String get menu_settings => 'Настройки';

  @override
  String get menu_enable_notifications => 'Включить уведомления';

  @override
  String get notifications_enabled => 'Уведомления включены';

  @override
  String get notifications_enable_in_settings =>
      'Включите уведомления в настройках приложения';

  @override
  String get menu_registration => 'Вход';

  @override
  String get menu_logout => 'Выйти';

  @override
  String get menu_admin_panel => 'Админ-панель';

  @override
  String get profile_menu_collapsible_listings_group => 'Объявления и чаты';

  @override
  String get profile_menu_collapsible_services_group =>
      'Уведомления и поддержка';

  @override
  String get manage_property => 'Управление жильём';

  @override
  String get admin_panel_title => 'Админ-панель';

  @override
  String get admin_panel_category_management => 'Пользователи и модерация';

  @override
  String get admin_panel_category_maps => 'Карты';

  @override
  String get admin_panel_category_analytics => 'Аналитика';

  @override
  String get admin_panel_category_settings => 'Настройки приложения';

  @override
  String get admin_client_settings_show_listing_contacts =>
      'Показывать контакты в объявлениях';

  @override
  String get admin_client_settings_show_listing_contacts_description =>
      'Telegram и звонок в «Совместимости» при указанных контактах.';

  @override
  String get admin_panel_section_content_moderation => 'Настройки клиента';

  @override
  String get admin_content_moderation_title => 'Настройки клиента';

  @override
  String get admin_settings_category_app_experience => 'Опыт в приложении';

  @override
  String get admin_settings_category_maps => 'Карты';

  @override
  String get admin_settings_category_listings => 'Объявления';

  @override
  String get admin_settings_category_moderation => 'Модерация и безопасность';

  @override
  String get admin_settings_category_telegram => 'Telegram';

  @override
  String get admin_settings_category_admin_tools => 'Инструменты админа';

  @override
  String get admin_map_layer_default_districts_title =>
      'Показывать районы по умолчанию';

  @override
  String get admin_map_layer_default_districts_subtitle =>
      'Границы и названия районов при первом открытии карты.';

  @override
  String get admin_map_layer_default_metro_title =>
      'Показывать метро по умолчанию';

  @override
  String get admin_map_layer_default_metro_subtitle =>
      'Станции метро при первом открытии карты.';

  @override
  String get admin_map_layer_default_universities_title =>
      'Показывать университеты по умолчанию';

  @override
  String get admin_map_layer_default_universities_subtitle =>
      'Маркеры университетов при первом открытии карты.';

  @override
  String get admin_content_moderation_description =>
      'Модерация фото (сервер): если включено, загружаемые фото проверяются на нежелательный контент; при срабатывании изображение размывается перед сохранением. Если выключено, проверка и размытие не выполняются (вызовы AWS Rekognition отключены).';

  @override
  String get admin_client_config_hide_gemini_listing_ui =>
      'Скрыть перевод и улучшение ИИ';

  @override
  String get admin_client_config_hide_gemini_listing_ui_description =>
      'Кнопки языка в описании и «Улучшить ИИ» при создании/редактировании.';

  @override
  String get admin_client_config_disable_lidar_room_scan =>
      'Отключить сканирование LiDAR';

  @override
  String get admin_client_config_disable_lidar_room_scan_description =>
      'Шаг скана после создания, кнопка в редакторе, загрузка.';

  @override
  String get admin_client_config_disable_custom_camera =>
      'Использовать кастомную камеру';

  @override
  String get admin_client_config_disable_custom_camera_description =>
      'Вкл — камера приложения с водяным знаком; выкл — системная.';

  @override
  String get admin_client_config_show_listing_dictation_meter =>
      'Индикатор уровня и таймер диктовки';

  @override
  String get admin_client_config_show_listing_dictation_meter_description =>
      'Волна и таймер при диктовке; иначе только микрофон/стоп.';

  @override
  String get admin_content_moderation_blur_enabled =>
      'Проверять и размывать нежелательные фото';

  @override
  String get admin_content_moderation_loading =>
      'Загрузка настроек модерации...';

  @override
  String get admin_content_moderation_error =>
      'Не удалось загрузить настройки модерации';

  @override
  String get admin_content_moderation_save_error =>
      'Не удалось сохранить настройку';

  @override
  String get admin_app_setting_listing_gig_moderation_queue_title =>
      'Ручное одобрение новых объявлений и гигов';

  @override
  String get admin_app_setting_listing_gig_moderation_queue_subtitle =>
      'Новые объявления и гиги скрыты до одобрения админом.';

  @override
  String get admin_app_setting_home_start_map_title =>
      'Открывать главную с карты';

  @override
  String get admin_app_setting_home_start_map_subtitle =>
      'Вкл — сначала карта. Выкл — сначала лента.';

  @override
  String get map_zoom_slider_toggle => 'Ползунок масштаба';

  @override
  String get map_zoom_slider_toggle_description =>
      'Показывать вертикальный регулятор масштаба на карте';

  @override
  String get admin_app_setting_listing_owner_conversations_title =>
      'Чаты по объявлению (админ)';

  @override
  String get admin_app_setting_listing_owner_conversations_subtitle =>
      'Когда включено, админ может открыть все in-app диалоги по объявлению с его экрана.';

  @override
  String get admin_app_setting_telegram_bridge_title =>
      'Telegram-мост сообщений';

  @override
  String get admin_app_setting_telegram_bridge_subtitle =>
      'Когда включено, авторы объявлений получают сообщения из чата UyDosh в боте и могут отвечать через него. Выкл — только классический чат в приложении.';

  @override
  String get admin_panel_section_telegram_sync => 'Импорт данных';

  @override
  String get admin_panel_section_area_price_cache => 'Ориентиры по ценам';

  @override
  String get admin_telegram_sync_title => 'Импорт данных';

  @override
  String get admin_telegram_sync_chat_label => 'Чат';

  @override
  String get admin_telegram_sync_limit_label => 'Лимит сообщений';

  @override
  String get admin_telegram_sync_import_user_label => 'ID владельца объявлений';

  @override
  String get admin_telegram_sync_import_user_helper =>
      'Аккаунт администратора, от имени которого создаются импортированные объявления. «Только синк БД» — без создания объявлений.';

  @override
  String get admin_telegram_sync_import_user_sync_only =>
      'Только синк БД (без импорта объявлений)';

  @override
  String get admin_telegram_sync_admins_loading => 'Загрузка списка админов…';

  @override
  String get admin_telegram_sync_admins_error =>
      'Не удалось загрузить список админов';

  @override
  String get admin_telegram_sync_admins_retry => 'Повторить';

  @override
  String get admin_telegram_sync_admins_empty => 'Админов не найдено.';

  @override
  String get admin_telegram_sync_newest_first => 'Сначала новые';

  @override
  String get admin_telegram_sync_skip_listing_import =>
      'Без импорта объявлений (только БД)';

  @override
  String get admin_telegram_sync_run => 'Запустить синк';

  @override
  String get admin_telegram_sync_running => 'Выполняется…';

  @override
  String get admin_telegram_sync_result_header => 'Результат';

  @override
  String get admin_telegram_sync_sync_section => 'Синк БД';

  @override
  String get admin_telegram_sync_listing_section => 'Импорт объявлений';

  @override
  String get admin_telegram_sync_invalid_chat_limit =>
      'Укажите чат (например @roommateuz).';

  @override
  String get admin_telegram_sync_invalid_import_user =>
      'ID пользователя должен быть положительным числом или пустым.';

  @override
  String get admin_area_price_cache_section_title =>
      'Кэш цен по району объявления';

  @override
  String get admin_area_price_cache_intro =>
      'Пересчитывает медиану и среднее по станциям, линиям метро и районам (оринтир на карточке объявления). Запускайте после крупных импортов из Telegram.';

  @override
  String get admin_area_price_cache_run => 'Обновить кэш цен';

  @override
  String get admin_area_price_cache_running => 'Пересчёт кэша…';

  @override
  String get admin_area_price_cache_screen_body =>
      'Пересобирает кэш медианы и средней аренды по станциям, линиям метро и районам (блок «ориентир по цене» в объявлении). Запускайте после крупного импорта из Telegram или если блок пустой.';

  @override
  String get admin_panel_section_users => 'Пользователи';

  @override
  String get admin_reassign_ownership_submit => 'Перенести';

  @override
  String get admin_reassign_ownership_success => 'Владелец обновлён';

  @override
  String get admin_reassign_owner_menu => 'Сменить владельца';

  @override
  String get admin_reassign_owner_dialog_title => 'Смена владельца';

  @override
  String get admin_reassign_owner_search_placeholder =>
      'Поиск по id, email или имени';

  @override
  String admin_reassign_owner_from_user(Object id) {
    return 'ID владельца: $id';
  }

  @override
  String admin_reassign_owner_listing_id(Object id) {
    return 'ID объявления: $id';
  }

  @override
  String admin_reassign_owner_gig_offer_id(Object id) {
    return 'ID предложения: $id';
  }

  @override
  String admin_reassign_owner_gig_request_id(Object id) {
    return 'ID заявки: $id';
  }

  @override
  String get admin_reassign_owner_empty => 'Пользователи не найдены.';

  @override
  String get admin_panel_section_support_chat => 'Поддержка';

  @override
  String get admin_panel_section_complaints => 'Жалобы';

  @override
  String get admin_panel_section_listing_complaints => 'Объявления с жалобами';

  @override
  String get admin_panel_section_listing_moderation => 'Модерация объявлений';

  @override
  String get admin_listing_moderation_title => 'На проверке';

  @override
  String get admin_listing_moderation_loading => 'Загрузка очереди модерации…';

  @override
  String get admin_listing_moderation_error => 'Не удалось загрузить очередь';

  @override
  String get admin_listing_moderation_retry => 'Повторить';

  @override
  String get admin_listing_moderation_summary_total => 'В очереди';

  @override
  String get admin_listing_moderation_summary_today => 'Сегодня';

  @override
  String get admin_listing_moderation_summary_oldest => 'Старше';

  @override
  String get admin_listing_moderation_days_short => 'дн.';

  @override
  String get admin_listing_moderation_section_list => 'Ожидают проверки';

  @override
  String get admin_listing_moderation_empty =>
      'Нет объявлений, ожидающих одобрения.';

  @override
  String get admin_listing_moderation_open => 'Открыть';

  @override
  String get admin_listing_moderation_approve => 'Одобрить';

  @override
  String get admin_listing_moderation_id => 'ID';

  @override
  String get admin_listing_moderation_user => 'Пользователь';

  @override
  String get admin_listing_moderation_load_more => 'Ещё';

  @override
  String get admin_listing_moderation_approved_toast =>
      'Объявление опубликовано';

  @override
  String get admin_listing_moderation_approve_confirm_title =>
      'Одобрить объявление?';

  @override
  String get admin_listing_moderation_approve_confirm_message =>
      'Объявление будет опубликовано и станет видно всем.';

  @override
  String get admin_panel_section_gig_moderation => 'Модерация услуг и задач';

  @override
  String get admin_gig_moderation_title => 'Модерация объявлений (гига)';

  @override
  String get admin_gig_moderation_tab_offers => 'Услуги';

  @override
  String get admin_gig_moderation_tab_requests => 'Задачи';

  @override
  String get admin_gig_moderation_section_offers => 'Услуги на проверке';

  @override
  String get admin_gig_moderation_section_requests => 'Задачи на проверке';

  @override
  String get admin_gig_moderation_empty_offers =>
      'Нет услуг, ожидающих одобрения.';

  @override
  String get admin_gig_moderation_empty_requests =>
      'Нет задач, ожидающих одобрения.';

  @override
  String get admin_gig_moderation_provider => 'Исполнитель';

  @override
  String get admin_gig_moderation_client => 'Заказчик';

  @override
  String get admin_gig_moderation_approved_offer_toast => 'Услуга опубликована';

  @override
  String get admin_gig_moderation_approved_request_toast =>
      'Задача опубликована';

  @override
  String get admin_panel_section_district_heatmap => 'Тепловая карта районов';

  @override
  String get admin_panel_section_subway_heatmap => 'Тепловая карта линий метро';

  @override
  String get admin_panel_section_subway_map => 'Схема метро';

  @override
  String get admin_panel_section_universities_map => 'Карта университетов';

  @override
  String get admin_universities_map_title => 'Карта университетов';

  @override
  String get admin_universities_map_error =>
      'Не удалось загрузить университеты';

  @override
  String get admin_universities_map_retry => 'Повторить';

  @override
  String get admin_universities_map_empty =>
      'Пока нет университетов с координатами для карты.';

  @override
  String get admin_panel_section_search_analytics => 'Аналитика поиска';

  @override
  String get admin_panel_section_listing_creation_analytics =>
      'Аналитика создания объявлений';

  @override
  String get admin_search_analytics_title => 'Аналитика поиска';

  @override
  String get admin_search_analytics_loading => 'Загрузка аналитики поиска...';

  @override
  String get admin_search_analytics_error => 'Не удалось загрузить аналитику';

  @override
  String get admin_search_analytics_retry => 'Повторить';

  @override
  String get admin_search_analytics_time_range => 'Период';

  @override
  String admin_search_analytics_days(String days) {
    return 'За $days дн.';
  }

  @override
  String get admin_search_analytics_all_time => 'Всё время';

  @override
  String get admin_search_analytics_total => 'Всего поисков';

  @override
  String get admin_search_analytics_today => 'Сегодня';

  @override
  String get admin_search_analytics_week => 'За неделю';

  @override
  String get admin_search_analytics_top_stations => 'Популярные станции метро';

  @override
  String get admin_search_analytics_top_districts => 'Популярные районы';

  @override
  String get admin_search_analytics_top_lines => 'Популярные линии метро';

  @override
  String get admin_search_analytics_searches => 'поисков';

  @override
  String get admin_search_analytics_no_stations => 'Нет данных по станциям';

  @override
  String get admin_search_analytics_no_districts => 'Нет данных по районам';

  @override
  String get admin_search_analytics_no_lines => 'Нет данных по линиям';

  @override
  String get admin_listing_creation_analytics_title =>
      'Аналитика создания объявлений';

  @override
  String get admin_listing_creation_analytics_loading =>
      'Загрузка аналитики создания объявлений...';

  @override
  String get admin_listing_creation_analytics_error =>
      'Не удалось загрузить аналитику';

  @override
  String get admin_listing_creation_analytics_retry => 'Повторить';

  @override
  String get admin_listing_creation_analytics_time_range => 'Период';

  @override
  String get admin_listing_creation_analytics_total => 'Всего за период';

  @override
  String get admin_listing_creation_analytics_today => 'Сегодня';

  @override
  String get admin_listing_creation_analytics_week => 'За неделю';

  @override
  String get admin_listing_creation_analytics_by_day => 'Объявления по дням';

  @override
  String get admin_listing_creation_analytics_no_data =>
      'Нет данных за выбранный период';

  @override
  String get admin_district_heatmap_title => 'Тепловая карта районов';

  @override
  String get admin_district_heatmap_description =>
      'Объявления по районам с цветовой интенсивностью.';

  @override
  String get admin_district_heatmap_loading =>
      'Загрузка статистики по районам...';

  @override
  String get admin_district_heatmap_error =>
      'Не удалось загрузить статистику по районам';

  @override
  String get admin_district_heatmap_retry => 'Повторить';

  @override
  String get admin_district_heatmap_total => 'Всего объявлений';

  @override
  String get admin_district_heatmap_max => 'Максимум в районе';

  @override
  String get admin_district_heatmap_count_label => 'Объявления';

  @override
  String get admin_district_heatmap_unavailable => 'Недоступно';

  @override
  String get admin_district_heatmap_no_data => 'Нет данных по районам';

  @override
  String get admin_subway_heatmap_title => 'Тепловая карта линий метро';

  @override
  String get admin_subway_heatmap_description =>
      'Объявления по линиям метро с цветовой интенсивностью.';

  @override
  String get admin_subway_heatmap_loading =>
      'Загрузка статистики по линиям метро...';

  @override
  String get admin_subway_heatmap_error =>
      'Не удалось загрузить статистику по линиям метро';

  @override
  String get admin_subway_heatmap_retry => 'Повторить';

  @override
  String get admin_subway_heatmap_total => 'Всего объявлений';

  @override
  String get admin_subway_heatmap_max => 'Максимум на линии';

  @override
  String get admin_subway_heatmap_count_label => 'Объявления';

  @override
  String get admin_subway_heatmap_unavailable => 'Недоступно';

  @override
  String get admin_subway_heatmap_no_data => 'Нет данных по линиям метро';

  @override
  String get admin_subway_map_title => 'Схема метро';

  @override
  String get admin_subway_map_description =>
      'Упрощенная схема с линиями и станциями.';

  @override
  String get error_loading_map => 'Не удалось загрузить карту';

  @override
  String get admin_users_title => 'Пользователи';

  @override
  String get admin_users_loading => 'Загрузка пользователей...';

  @override
  String get admin_users_empty => 'Пользователи не найдены';

  @override
  String get admin_users_error => 'Не удалось загрузить пользователей';

  @override
  String get admin_users_id => 'ID';

  @override
  String get admin_users_role => 'Роль';

  @override
  String get admin_users_created_at => 'Создан';

  @override
  String get admin_users_listings_count => 'Объявления';

  @override
  String get admin_users_listings_count_loading => 'Загрузка...';

  @override
  String get admin_users_listings_count_error => 'Недоступно';

  @override
  String get admin_user_detail_title => 'Пользователь';

  @override
  String get admin_user_detail_role_title => 'Управление ролью';

  @override
  String get admin_user_detail_role_label => 'Роль';

  @override
  String get admin_user_detail_role_save => 'Сохранить роль';

  @override
  String get admin_user_detail_role_updated => 'Роль обновлена';

  @override
  String get admin_user_detail_view_listings => 'Объявления пользователя';

  @override
  String get admin_user_detail_view_complaints => 'Жалобы пользователя';

  @override
  String get admin_user_detail_view_alerts => 'Оповещения пользователя';

  @override
  String get admin_user_detail_block_title => 'Блокировка';

  @override
  String get admin_user_detail_block => 'Заблокировать';

  @override
  String get admin_user_detail_unblock => 'Разблокировать';

  @override
  String get admin_user_detail_blocked => 'Заблокирован';

  @override
  String get admin_user_detail_block_reason => 'Причина';

  @override
  String get admin_user_detail_block_until => 'До';

  @override
  String get admin_user_detail_block_permanent => 'Постоянно';

  @override
  String get admin_user_detail_block_confirm => 'Заблокировать';

  @override
  String get admin_user_detail_blocked_success => 'Пользователь заблокирован';

  @override
  String get admin_user_detail_unblocked_success =>
      'Пользователь разблокирован';

  @override
  String get admin_user_detail_devices_title => 'Устройства';

  @override
  String get admin_user_detail_devices_empty =>
      'Нет зарегистрированных устройств';

  @override
  String get admin_user_detail_devices_last_seen => 'Последняя активность';

  @override
  String get admin_user_detail_devices_model_unknown =>
      'Неизвестное устройство';

  @override
  String get admin_user_detail_devices_details_unknown => 'Нет данных';

  @override
  String get admin_user_detail_devices_app_prefix => 'Приложение';

  @override
  String get admin_user_complaints_title => 'Жалобы пользователя';

  @override
  String get admin_user_complaints_user => 'Пользователь';

  @override
  String get admin_user_complaints_empty => 'Жалобы не найдены';

  @override
  String get admin_user_complaints_group_count => 'Жалобы';

  @override
  String get admin_user_listings_title => 'Объявления пользователя';

  @override
  String get admin_user_listings_user => 'Пользователь';

  @override
  String get admin_user_listings_empty => 'Объявления не найдены';

  @override
  String get admin_user_listings_error => 'Не удалось загрузить объявления';

  @override
  String get admin_user_alerts_title => 'Оповещения пользователя';

  @override
  String get admin_user_alerts_empty => 'Оповещений не найдено';

  @override
  String get admin_complaints_title => 'Жалобы';

  @override
  String get admin_complaints_loading => 'Загрузка жалоб...';

  @override
  String get admin_complaints_empty => 'Жалобы не найдены';

  @override
  String get admin_complaints_error => 'Не удалось загрузить жалобы';

  @override
  String get admin_complaints_filter_all => 'Все';

  @override
  String get admin_complaints_filter_pending => 'В ожидании';

  @override
  String get admin_complaints_filter_resolved => 'Решено';

  @override
  String get admin_complaints_filter_dismissed => 'Отклонено';

  @override
  String get admin_complaints_status_label => 'Статус';

  @override
  String get admin_complaints_status_pending => 'В ожидании';

  @override
  String get admin_complaints_status_resolved => 'Решено';

  @override
  String get admin_complaints_status_dismissed => 'Отклонено';

  @override
  String get admin_complaints_listing_id => 'Объявление';

  @override
  String get admin_complaints_complainant_id => 'Пользователь';

  @override
  String get admin_complaints_category_unknown => 'Неизвестная категория';

  @override
  String get admin_complaints_created_at => 'Создан';

  @override
  String get admin_complaints_text => 'Описание';

  @override
  String get admin_complaints_update_status => 'Обновить статус';

  @override
  String get admin_complaints_status_updated => 'Статус обновлен';

  @override
  String get admin_complaints_view_author => 'Профиль пользователя';

  @override
  String get admin_support_chat_title => 'Поддержка';

  @override
  String get admin_support_chat_loading => 'Загрузка обращений...';

  @override
  String get admin_support_chat_empty => 'Обращений пока нет';

  @override
  String get admin_support_chat_error => 'Не удалось загрузить поддержку';

  @override
  String get admin_support_chat_retry => 'Повторить';

  @override
  String get admin_support_chat_filter_all => 'Все';

  @override
  String get admin_support_chat_filter_open => 'Открытые';

  @override
  String get admin_support_chat_filter_closed => 'Закрытые';

  @override
  String get admin_support_chat_status_open => 'Открыт';

  @override
  String get admin_support_chat_status_closed => 'Закрыт';

  @override
  String get admin_support_chat_messages => 'сообщений';

  @override
  String get admin_support_chat_yesterday => 'Вчера';

  @override
  String get admin_support_chat_days_ago => 'дн. назад';

  @override
  String get admin_support_chat_no_messages => 'Сообщений пока нет';

  @override
  String get admin_support_chat_reply_hint => 'Введите ответ...';

  @override
  String get admin_support_chat_close_thread => 'Закрыть обращение';

  @override
  String get admin_support_chat_reopen_thread => 'Открыть снова';

  @override
  String get admin_support_chat_closed => 'Обращение закрыто';

  @override
  String get admin_support_chat_reopened => 'Обращение открыто';

  @override
  String get admin_support_chat_thread_closed =>
      'Обращение закрыто. Откройте, чтобы ответить.';

  @override
  String get contact_support_title => 'Поддержка';

  @override
  String get contact_support_loading => 'Загрузка...';

  @override
  String get contact_support_error => 'Не удалось загрузить поддержку';

  @override
  String get contact_support_empty =>
      'Обращений пока нет. Создайте новое, чтобы получить помощь.';

  @override
  String get contact_support_new => 'Новое обращение';

  @override
  String get contact_support_message_hint => 'Введите сообщение...';

  @override
  String get admin_listing_complaints_title => 'Объявления с жалобами';

  @override
  String get admin_listing_complaints_empty => 'Объявлений с жалобами нет';

  @override
  String get admin_listing_complaints_error =>
      'Не удалось загрузить объявления с жалобами';

  @override
  String get admin_listing_complaints_last_reported => 'Последняя жалоба';

  @override
  String get admin_listing_complaints_categories => 'Жалобы';

  @override
  String get admin_listing_complaints_categories_empty => 'Нет категорий жалоб';

  @override
  String get faq_question =>
      'Как договариваться с соседями и избегать конфликтов?';

  @override
  String get faq_answer =>
      'Жить вместе — это всегда про уважение и умение договариваться. Вот несколько простых правил, которые помогут сохранить мир и дружбу:\n\nШум\nДоговоритесь о «тихих часах». Для музыки — наушники, для звонков — коридор или улица. Удобно повесить расписание, чтобы все знали, когда у кого учеба или отдых.\n\nГости\nПредупреждайте друг друга заранее. Хорошее правило — определённые дни для гостей и дни для тишины.\n\nЭмоции\nНе копите раздражение. Говорите спокойно и сразу, если что-то мешает. А лишний стресс лучше выплеснуть в спортзале или на пробежке.\n\nОбщие дела\nИногда полезно что-то делать вместе: сходить в кино, прогуляться, устроить «уборку под музыку». Общие воспоминания укрепляют дружбу.\n\nУборка и быт\nРазделите обязанности — кто-то моет пол, кто-то выносит мусор. Главное — договариваться и уважать личные границы. Чужие вещи без спроса не трогаем.\n\nОбщение\nИспользуйте «я-сообщения»: вместо «ты меня бесишь» лучше сказать «мне тяжело сосредоточиться, когда играет громкая музыка».\n\nРешение конфликтов\nСтарайтесь обсуждать всё спокойно, выслушивая друг друга. Конфликт — это повод найти общее решение, а не врага.\n\nЕда\nМожно договориться о совместных покупках или завести «общую полочку» для вкусняшек.\n\nПорядок и тишина\nГрафик уборки — лучший друг. А если нужно сосредоточиться — можно уйти в библиотеку или коворкинг, либо снова включить правило «тихого часа».';

  @override
  String get faq_question_2 => 'Неожиданный счёт за чужую коммуналку';

  @override
  String get faq_answer_2 =>
      'Иногда вместе с квартирой жильцу «в подарок» достаются и долги за коммунальные услуги. В итоге — отключённый свет или вода, а арендодатель не спешит платить. Жильцу остаётся выбирать: съезжать с убытками или гасить долг за свой счёт.\n\nЧтобы избежать таких ситуаций:\n\nПроверка перед подписанием\nПеред подписанием договора попросите у хозяина квитанции или отчёт об оплаченных коммунальных платежах.\n\nПисьменное соглашение\nЕсли долг всё-таки есть и вы готовы его оплатить, обязательно оформите письменное соглашение: сумма долга будет зачтена в счёт будущей аренды.\n\nТак вы сохраните и деньги, и спокойствие.';

  @override
  String get faq_question_3 => 'Обещания арендодателя: ремонт, техника, мебель';

  @override
  String get faq_answer_3 =>
      'Нередко при аренде жилья собственник обещает устранить неисправности в квартире, купить бытовую технику и мебель. Все это он обязуется исполнить сразу после заселения. Однако проходит время, а неисправности так и остаются. Чтобы не стать заложником подобной ситуации, арендатору следует прописать в договоре найма особые условия.\n\nТакже нередко нарушается устная договоренность о выполнении ремонта силами квартиранта и обязательство не взимать арендную плату во время проведения работ. Например, вы делаете ремонт квартиры за свой счет и не платите за аренду несколько месяцев. Однако некоторые арендодатели «забывают» о договоренностях и требуют оплаты проживания. Зачастую у сторон возникают разногласия по поводу стоимости отделки, а иногда дело и вовсе доходит до суда.\n\nПоэтому следует обсудить все моменты ремонта, учесть их в договоре найма, а также составить смету и подписать её.';

  @override
  String get faq_question_4 => 'О Важности Договора';

  @override
  String get faq_answer_4 =>
      'Часто при сдаче жилья родственникам или друзьям договор не заключаются. При этом, многие скандалы и разбирательства происходят как раз между родственниками и друзьями, которые приняли обещания и обязательства по аренде на словах. Поэтому лучше заключить договор, даже если вы снимаете квартиру у своего дяди или близкого друга.\n\nЕсть случаи, когда квартиры сдаются по доверенности, где указано: доверитель дает доверенному лицу право сдать его квартиру внаем. «Но в доверенности не прописано, что доверенное лицо имеет также право получать арендную плату. Может произойти ситуация: квартирант исправно вносит арендную сумму доверенному лицу, но однажды появляется собственник жилплощади и требует арендатора оплатить прошедший период проживания в квартире». В данном случае следует тщательно изучать документы, и если в доверенности не указано право на получение арендной платы, обсудить этот пункт.';

  @override
  String get faq_question_5 => 'Гайд по безопасности для арендаторов и соседей';

  @override
  String get faq_answer_5 =>
      'Иногда происходят неприятные ситуации не только на нашей платформе. К сожалению, неадекватные или озабоченные люди встречаются везде. Поэтому важно помнить о простых правилах безопасности.\n\n🙏 Главное — ваша безопасность!\n\nПеред встречей\n• Договаривайтесь о встречах только в дневное время.\n• Старайтесь выбирать людные места — кафе, торговый центр, двор с камерами.\n• Сообщите друзьям или родным, куда идёте и с кем встречаетесь.\n\nВо время встречи\n• По возможности приходите не одни.\n• Не передавайте деньги и документы «из рук в руки» до подписания договора.\n• Сохраняйте переписку и фото/сканы документов — это ваша защита.\n\nЕсли чувствуете угрозу\n• Немедленно прекращайте встречу и уходите.\n• Не бойтесь сказать «нет» и оборвать общение.\n• При явной опасности — звоните 102 или обращайтесь в ближайшее отделение РОВД.\n\nНа платформе UyDosh\n• Пользуйтесь системой верификации — проверенные профили снижают риск.\n• Сообщайте модераторам о подозрительных объявлениях и поведении.\n• Помните: лучше перестраховаться, чем потом сожалеть.\n\n❤️ Берегите себя и друг друга!';

  @override
  String get logout_confirmation => 'Подтверждение выхода';

  @override
  String get logout_description =>
      'Вы уверены, что хотите выйти? Вам нужно будет снова войти, чтобы получить доступ к профилю.';

  @override
  String get logout => 'Выйти';

  @override
  String get logout_success => 'Вы успешно вышли из системы';

  @override
  String get session_expired => 'Сессия истекла. Пожалуйста, войдите снова.';

  @override
  String get delete_account => 'Удалить аккаунт';

  @override
  String get delete_account_confirmation =>
      'Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить. Все ваши данные, объявления и сообщения будут безвозвратно удалены.';

  @override
  String get delete_account_success => 'Аккаунт успешно удалён';

  @override
  String get delete_account_error => 'Ошибка удаления аккаунта';

  @override
  String get delete_account_blocked =>
      'Ваш аккаунт ограничен. Вы не можете удалить аккаунт, пока он заблокирован. Обратитесь в службу поддержки.';

  @override
  String get nav_my => 'Моё';

  @override
  String get my_hub_tab_groups => 'Группы';

  @override
  String get my_hub_tab_bookmarks => 'Варианты жилья';

  @override
  String get my_hub_tab_alerts => 'Мои оповещения';

  @override
  String get favorites_title => 'Избранное';

  @override
  String get favorites_empty_title => 'Пока нет избранного';

  @override
  String get favorites_tab_listings => 'Жильё';

  @override
  String get favorites_tab_services => 'Услуги';

  @override
  String get favorites_tab_tasks => 'Задачи';

  @override
  String get favorites_browse_button => 'Просмотреть объявления';

  @override
  String get view_history_title => 'История просмотров';

  @override
  String get view_history_empty_title => 'Пока нет просмотренных объявлений';

  @override
  String get view_history_browse_button => 'Просмотреть объявления';

  @override
  String get view_history_auth_prompt => 'Войдите, чтобы просмотреть историю.';

  @override
  String get unable_to_load_view_history =>
      'Не удалось загрузить историю. Попробуйте позже.';

  @override
  String get menu_achievements => 'Достижения';

  @override
  String get achievements_title => 'Достижения';

  @override
  String get achievement_unlocked => 'Достижение разблокировано!';

  @override
  String get achievement_first_steps => 'Первые шаги';

  @override
  String get achievement_first_steps_desc => 'Создайте аккаунт';

  @override
  String get achievement_profile_complete => 'Профиль заполнен';

  @override
  String get achievement_profile_complete_desc => 'Заполните профиль на 100%';

  @override
  String get achievement_first_look => 'Первый взгляд';

  @override
  String get achievement_first_look_desc => 'Просмотрите первое объявление';

  @override
  String get achievement_bookmarker => 'В закладках';

  @override
  String get achievement_bookmarker_desc => 'Добавьте первое избранное';

  @override
  String get achievement_ice_breaker => 'Разговор начат';

  @override
  String get achievement_ice_breaker_desc => 'Отправьте первое сообщение';

  @override
  String get achievement_first_listing => 'Первое объявление';

  @override
  String get achievement_first_listing_desc => 'Создайте первое объявление';

  @override
  String get achievement_returning_user => 'Постоянный пользователь';

  @override
  String get achievement_returning_user_desc =>
      'Используйте приложение 7 дней подряд';

  @override
  String get achievement_sharer => 'Поделился';

  @override
  String get achievement_sharer_desc => 'Поделитесь первым объявлением';

  @override
  String get achievements_empty => 'Пока нет достижений';

  @override
  String get achievements_empty_desc =>
      'Выполняйте действия, чтобы разблокировать достижения';

  @override
  String get achievements_auth_prompt =>
      'Войдите, чтобы просмотреть достижения';

  @override
  String get favorite_toggle_error => 'Не удалось обновить статус избранного';

  @override
  String get favorite_toggle_network_error =>
      'Ошибка сети при обновлении статуса избранного';

  @override
  String get unable_to_load_favorites =>
      'Не удалось загрузить избранное. Попробуйте позже.';

  @override
  String get create_listing_title => 'Опубликовать';

  @override
  String get edit_listing => 'Редактировать объявление';

  @override
  String get edit_profile => 'Редактировать профиль';

  @override
  String get updating_listing => 'Обновляется...';

  @override
  String get creating_listing => 'Создается...';

  @override
  String get title_required => 'Заголовок обязателен';

  @override
  String get title_too_long => 'Заголовок должен быть не более 50 символов';

  @override
  String get description_required => 'Описание обязательно';

  @override
  String get description_too_long =>
      'Описание должно быть не более 500 символов';

  @override
  String get location_required => 'Пожалуйста, выберите район';

  @override
  String get location_metro_required => 'Пожалуйста, выберите станцию метро';

  @override
  String get location_district_required => 'Пожалуйста, выберите район';

  @override
  String get price_required => 'Пожалуйста, укажите цену';

  @override
  String get listing_price_minimum => 'Цена должна быть не менее 1 USD в месяц';

  @override
  String get auth_required_title => 'Требуется аутентификация';

  @override
  String get authentication_required =>
      'Требуется аутентификация. Пожалуйста, войдите в систему для создания объявлений.';

  @override
  String get unauthenticated_listing_prompt =>
      'Для создания и размещения объявлений необходимо войти в свой аккаунт.';

  @override
  String get authenticate_to_post_listing => 'Войти для размещения объявления';

  @override
  String get select_location_required => 'Выберите район';

  @override
  String get select_metro_line_optional => 'Линия метро';

  @override
  String get amenities => 'Удобства';

  @override
  String get photos => 'Фотографии';

  @override
  String get primary => 'Основное';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get bed => 'Кровать';

  @override
  String get air_conditioning => 'Кондиционер';

  @override
  String get tv => 'Телевизор';

  @override
  String get microwave => 'Микроволновка';

  @override
  String get washing_machine => 'Стиралка';

  @override
  String get pets => 'Домашние животные разрешены';

  @override
  String get month => 'месяц';

  @override
  String get search_listings => 'Поиск объявлений';

  @override
  String get search => 'Поиск';

  @override
  String get filters_bar_label => 'Фильтры';

  @override
  String get search_alert_notify_me => 'Уведомлять';

  @override
  String get search_alert_bell_hint =>
      'Получать уведомления о похожих объявлениях';

  @override
  String get search_alert_login_required =>
      'Войдите, чтобы получать уведомления по этому поиску.';

  @override
  String get search_alert_created =>
      'Мы сообщим, когда появятся подходящие объявления.';

  @override
  String get search_alert_failed =>
      'Не удалось сохранить оповещение. Попробуйте снова.';

  @override
  String get search_alert_station_already_covered =>
      'Эта станция уже входит в ваши оповещения.';

  @override
  String search_alert_station_already_covered_by_line(
      String station, String line) {
    return 'Станция $station уже входит в ваше оповещение по линии $line.';
  }

  @override
  String get search_alert_permission =>
      'Включите уведомления в настройках, чтобы получать оповещения.';

  @override
  String get search_alert_updated => 'Оповещение обновлено.';

  @override
  String get tutorial_search_title => 'Поиск объявлений';

  @override
  String get tutorial_search_description =>
      'Здесь можно выбрать район, цену и другие фильтры.';

  @override
  String get tutorial_profile_description =>
      'Здесь находятся ваш профиль и настройки аккаунта.';

  @override
  String get tutorial_got_it => 'Понятно';

  @override
  String get tutorial_metro_description =>
      'Выберите линию метро, затем станцию для фильтрации по местоположению.';

  @override
  String get tutorial_alert_bell_description =>
      'Включите оповещение о новых объявлениях.';

  @override
  String get tutorial_notifications_bell_description =>
      'Ваши оповещения здесь. Нажмите, чтобы управлять ими.';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String get select_date => 'Дата вселения';

  @override
  String get move_in_date_label => 'Дата вселения:';

  @override
  String get publication_date => 'Опубликовано:';

  @override
  String get sign_in_with_google => 'Войти через Google';

  @override
  String get sign_in_with_google_or_apple => 'Войти через Google или Apple';

  @override
  String get sign_in_oauth_prompt => 'Войдите, чтобы продолжить';

  @override
  String get sign_in_oauth_continue => 'Продолжить';

  @override
  String get auth_wizard_oauth_step_header => 'Войти в UyDosh';

  @override
  String get successfully_logged_in => 'Вы успешно вошли';

  @override
  String get signing_in => 'Вход в систему...';

  @override
  String google_sign_in_failed(String error) {
    return 'Ошибка входа через Google: $error';
  }

  @override
  String get popup_closed => 'Окно входа было закрыто';

  @override
  String get sign_in_with_apple => 'Войти через Apple';

  @override
  String get sign_in_with_telegram => 'Войти через Telegram';

  @override
  String get telegram_login_continue_in_browser =>
      'Завершите вход в браузере, затем вернитесь в приложение.';

  @override
  String telegram_sign_in_failed(Object error) {
    return 'Вход через Telegram не удался: $error';
  }

  @override
  String get successfully_signed_in_apple => 'Успешный вход через Apple!';

  @override
  String get successfully_signed_in_telegram => 'Успешный вход через Telegram!';

  @override
  String apple_sign_in_failed(String error) {
    return 'Ошибка входа через Apple: $error';
  }

  @override
  String get check_out_listing_on_uydosh =>
      'Посмотрите это объявление на UyDosh!';

  @override
  String get share_subject_uz => 'UyDosh - Uy e\'loni';

  @override
  String get share_subject_ru => 'UyDosh - Объявление о жилье';

  @override
  String get share_subject_en => 'UyDosh - Housing Listing';

  @override
  String get contact_user => 'Связаться с пользователем';

  @override
  String get follow => 'Подписаться';

  @override
  String get following => 'Подписан';

  @override
  String followers_count_one(String count) {
    return '$count подписчик';
  }

  @override
  String followers_count_other(String count) {
    return '$count подписчиков';
  }

  @override
  String following_count_one(String count) {
    return '$count подписка';
  }

  @override
  String following_count_other(String count) {
    return '$count подписок';
  }

  @override
  String get followers_list_title => 'Подписчики';

  @override
  String get following_list_title => 'Подписки';

  @override
  String get no_followers_yet => 'Пока нет подписчиков';

  @override
  String get no_following_yet => 'Пока нет подписок';

  @override
  String get common_connections => 'Общие связи';

  @override
  String common_connections_count(String count) {
    return '$count';
  }

  @override
  String get message => 'Написать';

  @override
  String get uydosh_chat => 'Чат UyDosh';

  @override
  String get delete_listing => 'Удалить объявление';

  @override
  String get delete_listing_confirmation =>
      'Вы уверены, что хотите удалить это объявление? Это действие нельзя отменить.';

  @override
  String get delete_listing_success => 'Объявление успешно удалено';

  @override
  String get delete_listing_error => 'Ошибка удаления объявления';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get create_complaint => 'Создать жалобу';

  @override
  String get complaint_description_hint =>
      'Добавьте подробности (необязательно)';

  @override
  String get submit_complaint => 'Отправить жалобу';

  @override
  String get complaint_created_success => 'Жалоба успешно отправлена';

  @override
  String get listing_complaints => 'Жалобы по объявлению';

  @override
  String listing_complaints_header(String count) {
    return 'Жалобы по объявлению: $count';
  }

  @override
  String get view_listing_complaints => 'Показать жалобы';

  @override
  String complaints_count_short(String count) {
    return '$count жалоб';
  }

  @override
  String get no_listing_complaints => 'Жалоб по этому объявлению пока нет';
}
