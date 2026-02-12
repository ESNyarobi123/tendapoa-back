# Full App Localization – Mwongozo

## Wazo

**Kubadilisha lugha mahali popote (login, welcome, au Settings) inabadilisha app nzima.**  
Lugha inahifadhiwa kwenye `SharedPreferences` (`app_language`). `MaterialApp.locale` inatoka `SettingsProvider`, hivyo kila skrini inayotumia **`context.tr('key')`** inaonyesha maandishi kwa lugha iliyochaguliwa.

## Flow

1. **Mtumiaji anachagua lugha** – Login (SW | EN), Welcome (SW | EN), au Settings → Lugha.
2. **`SettingsProvider.setLocale(Locale('sw' | 'en'))`** – inahifadhi kwenye prefs na kuita `notifyListeners()`.
3. **`MaterialApp` inajenga upya** – `locale: settings.locale` inabadilika.
4. **Kila `context.tr('key')`** inarudisha tafsiri ya lugha mpya (kutoka `app_en.arb` / `app_sw.arb`).
5. **API** – `ApiService` inaongeza header `Accept-Language: sw|en` kwa kila request (kutoka prefs), hivyo backend inarudisha title/description kwa lugha sahihi.

## Skrini zilizotengenezwa (full/localized)

| Skrini | Mabadiliko |
|--------|------------|
| **Login** | Toggle SW/EN + maandishi yote kupitia `context.tr()` (login_* keys). |
| **Welcome** | Toggle SW/EN; vitengo na maandishi kutoka welcome_title_1/2/3, welcome_subtitle_*, skip, start_now, continue_btn, welcome_have_account, welcome_login_link. |
| **Role select** | Kichwa na maelezo: role_select_title, role_select_subtitle; kadi: role_muhitaji_*, role_mfanyakazi_*; kiungo: welcome_have_account, welcome_login_link. |
| **Register** | Sehemu zote: register_* (labels, errors, location, buttons, terms). |
| **Settings** | Lugha switcher + refetch; maandishi: settings, account, edit_profile, language, logout, n.k. |
| **Client home** | Bottom nav (nyumbani_nav, kazi_zangu_nav, inbox_nav, dash_nav); kitufe FUTA/LIPIA TENA; dialog Futa Kazi (confirm_delete_*, no, yes_delete); withdrawal snackbars (min_amount_error, insufficient_balance_error, fill_all_fields, withdrawal_submitted, error_prefix). |
| **Worker home** | Bottom nav (sawa na client). |
| **Splash** | appTitle, splash_tagline. |
| **Post job** | post_job_new, steps, labels (enter_job_title, select_category, your_budget, additional_details), hints/errors, location (location_title, post_location_help, post_retry_location), nearby workers (post_searching_workers, post_no_workers_nearby, post_workers_found, post_job_visible_soon), post_continue_btn, post_job_btn. |
| **Edit profile** | choose_photo, camera, gallery, edit_profile, register_section_personal, register_full_name, login_email_label, phone_number, save_changes, profile_updated, error_prefix. |
| **Notifications** | today, yesterday, notifications, mark_all_read, no_notifications, notifications_empty_sub. |

## Skrini zinazoweza kuendelea

- **Client:** edit_job_screen, payment_wait_screen.
- **Worker:** worker_dashboard_screen, worker_jobs_screen, wallet_screen, withdrawal_screen, worker_active_job_screen.
- **Common:** map_screen, job_details_screen, chat_list_screen, chat_room_screen.
- **Widgets** – job_card, filter_modal, n.k. – tumia context.tr() kwa labels.

## Kuongeza funguo mpya

1. Ongeza kwenye **`lib/l10n/app_en.arb`** na **`lib/l10n/app_sw.arb`** (key sawa, thamani tofauti).
2. Tekeleza **`flutter gen-l10n`**.
3. Ongeza **case** kwenye **`lib/core/localization/app_localizations.dart`** (extension `tr()`): `case 'your_key': return loc.your_key;`
4. Tumia kwenye UI: **`context.tr('your_key')`**.

## Hitimisho

Ukibadilisha lugha kwenye **login** (au welcome/settings), **app nzima** inapaswa kuonyesha lugha ile ile kwa skrini zote zinazotumia `context.tr()`. Ili “full app” iwe kamili, kila skrini inabidi kuwa na maandishi yake kwa lugha kupitia funguo za l10n na `context.tr()`.
