# TendaPoa – Mwongozo wa UI/UX na Mapendekezo ya Utekelezaji

Hati hii inaelezea **hali ya sasa** ya UI/UX ya app, **mfumo wa rangi**, **font na maandishi**, **vitone**, na **wazo la utekelezaji** ili app iwe na muonekano na hisia sawa kila mahali.

---

## 1. Hali ya sasa (kile kilichopo)

### Kile kinachofanya kazi vizuri
- **Design system** ipo: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppTheme` (theme nzima).
- **Font**: Poppins ( headings / labels / buttons ), Inter ( body ) – tayari kwenye `AppTextStyles`.
- **Vitone**: `PrimaryButton`, `SecondaryButton`, `AccentButton` zipo kwenye `lib/ui/widgets/buttons.dart` na zinatumia `AppColors` na `AppSpacing`.
- **Theme**: `AppTheme.lightTheme` ina appBar, card, input, elevated/outlined button, bottom nav, snackbar, n.k.

### Tatizo kuu
- **Skrini nyingi** hazitumii design system kikamilifu: zina **rangi za moja kwa moja** (`Color(0xFF1E293B)`, `Color(0xFF64748B)`, `Color(0xFFF97316)` n.k.) na **maandishi ya inline** (`TextStyle(fontSize: 18, fontWeight: FontWeight.bold)`).
- **Rangi tofauti** kwa dhana moja: bluu tofauti (0xFF2563EB vs 0xFF1E3A8A), orange tofauti (0xFFF97316 vs 0xFFF59E0B), n.k.
- **Ukubwa wa font** hauna kiwango thabiti: 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 28, 32, 36 zimetumika bila scale maalum.
- **Vitone**: nyingi zimejengwa kwa `ElevatedButton`/`TextButton` na style zote ndani ya skrini badala ya kutumia widget za kawaida au theme.

Matokeo: app inaonekana “mixed” – sehemu zinaonekana za design system, nyingine za “custom” bila kiwango.

---

## 2. Mfumo wa rangi (Color combo) – mapendekezo

### 2.1 Palette ya kutumia kila mahali (kutoka `AppColors`)

| Matumizi        | Rangi / Constant        | Hex (kumbukumbu)   | Mfano wa matumizi                    |
|-----------------|-------------------------|--------------------|--------------------------------------|
| **Primary**     | `AppColors.primary`     | #2563EB (bluu)     | Bottom nav selected, CTA, links      |
| **Primary dark**| `AppColors.primaryDark` | #1E40AF            | App bar gradient, emphasis           |
| **Accent**      | `AppColors.accent`      | #F59E0B (amber)    | FAB, alerts, “toa pesa” accent        |
| **Background**  | `AppColors.background`  | #F8FAFC            | Scaffold ya skrini nyingi             |
| **Surface**     | `AppColors.surface`     | #FFFFFF            | Kadi, form, app bar                  |
| **Maandishi**   | `AppColors.textPrimary` | #0F172A            | Kichwa, maandishi makuu              |
| **Maandishi ya pili** | `AppColors.textSecondary` | #64748B     | Maelezo, labels dhaifu                |
| **Maandishi ya mwisho** | `AppColors.textLight` | #94A3B8        | Placeholder, captions                 |
| **Mafanikio**   | `AppColors.success`     | #10B981            | Snackbar nzuri, status “completed”   |
| **Hitilafu**    | `AppColors.error`       | #EF4444            | Snackbar error, validation, delete    |
| **Onyo**        | `AppColors.warning`     | #F59E0B            | Warning messages, “payment required” |

### 2.2 Rangi maalum (Worker / Pesa)

- **Wallet / Withdraw / Pesa (orange)**  
  Sasa skrini za worker (dashboard, wallet, withdrawal) zina `Color(0xFFF97316)`. Ili kuwa na **combo thabiti** na design system:
  - **Chaguo A**: Tumia `AppColors.accent` (#F59E0B) kila mahali badala ya 0xFFF97316 – orange moja kwa app.
  - **Chaguo B**: Ongeza `AppColors.walletAccent = Color(0xFFF97316)` kwenye `app_colors.dart`, na uitumie **tu** kwenye wallet/withdraw (balance card, withdraw button). Hii inabaki na “orange ya pesa” lakini iko kwenye palette ya kawaida.

Mapendekezo: **Chaguo A** kwa urahisi; ikiwa unataka orange tofauti kwa “pesa”, fanya **Chaguo B** na uweke kwenye `app_colors.dart` na uitumie tu kwenye sehemu za wallet/withdraw.

### 2.3 Kuepuka

- Usitumie `Color(0xFF...)` moja kwa moja kwenye UI. Tumia **daima** constant kutoka `AppColors` (au theme).
- Usiweke rangi mpya kwa “kichwa”, “maandishi”, “error” n.k. bila kuongeza kwenye `AppColors` na kutumia semantic (textPrimary, error, n.k.).

---

## 3. Font na ukubwa wa maandishi (Typography)

### 3.1 Scale iliyopendekezwa (kutoka `AppTextStyles`)

| Kiwango     | Constant           | Ukubwa (px) | Matumizi                                      |
|------------|--------------------|-------------|-----------------------------------------------|
| **H1**     | `AppTextStyles.h1` | 28          | Kichwa kikuu pekee kwenye skrini (splash, login) |
| **H2**     | `AppTextStyles.h2` | 24          | Kichwa cha skrini (title ya ukurasa)           |
| **H3**     | `AppTextStyles.h3` | 20          | Kichwa cha kundi (section title)              |
| **H4**     | `AppTextStyles.h4` | 17          | Kichwa kidogo (card title, dialog title)      |
| **H5**     | `AppTextStyles.h5` | 15          | Label kubwa, tab                              |
| **H6**     | `AppTextStyles.h6` | 14          | Subheading, list title                        |
| **Body large**  | `AppTextStyles.bodyLarge`  | 14 | Paragraph kuu                          |
| **Body medium** | `AppTextStyles.bodyMedium` | 13 | Paragraph ya kawaida                  |
| **Body small**  | `AppTextStyles.bodySmall`  | 11 | Maelezo madogo, meta                 |
| **Label large** | `AppTextStyles.labelLarge`| 13 | Label za form, chips                 |
| **Button**      | `AppTextStyles.buttonLarge` | 14 | Maandishi ya vitone (Poppins 600) |
| **Caption**     | `AppTextStyles.caption`    | 12 | Date, placeholders, hint            |
| **Price**       | `AppTextStyles.price`      | 14 | Bei (bold, primary color)           |

### 3.2 Sheria za matumizi

- **Kichwa cha skrini**: `AppTextStyles.h1` au `h2` (sio `TextStyle(fontSize: 28, ...)`).
- **Maelezo chini ya kichwa**: `AppTextStyles.bodyLarge` au `bodyMedium`, au `caption` ikiwa ni maelezo dhaifu.
- **Label za form**: `AppTextStyles.labelLarge` au `h5`/`h6`.
- **Vitone**: Theme ina tayari `fontSize: 16` kwa elevated/outlined; ikiwa unataka kiwango cha “button text” cha design system, tumia `AppTextStyles.buttonLarge` (14) au uongeze `buttonMedium` 16 kwenye `AppTextStyles` na uitumie kwenye theme.
- **Bei**: `AppTextStyles.price` kila mahali bei inaonekana.

Ili kufanya implement: **badilisha** kila `TextStyle(fontSize: X, fontWeight: ..., color: ...)` kuwa `AppTextStyles.xxx` (na `.copyWith(color: AppColors.yyy)` ikiwa unahitaji rangi tofauti mara chache).

---

## 4. Vitone (Buttons)

### 4.1 Aina na matumizi

| Aina            | Widget / Theme           | Matumizi                                      |
|-----------------|---------------------------|-----------------------------------------------|
| **Primary**     | `PrimaryButton` / `ElevatedButton` (theme) | CTA kuu: Ingia, Sajili, Hifadhi, Tuma |
| **Secondary**   | `SecondaryButton` / `OutlinedButton` (theme) | Cancel, “Ona zote”, actions za pili   |
| **Accent**      | `AccentButton`            | Toa pesa, FAB, action ya “pesa”              |
| **Text**        | `TextButton`              | “Skip”, “Ghairi”, link-style actions          |
| **Danger**      | `ElevatedButton` style error | Futa, Ondoa (nyekundu)                    |

### 4.2 Ukubwa na spacing

- **Urefu**: `AppSpacing.buttonHeightMd` (48) kwa kawaida; `buttonHeightLg` (56) kwa CTA kubwa (kama “HIFADHI MABADILIKO”).
- **Padding**: `EdgeInsets.symmetric(horizontal: 24, vertical: 14)` – tayari kwenye theme.
- **Radius**: `AppSpacing.borderRadiusMd` (12) au `borderRadiusLg` (16) kwa vitone vya ukurasa.

### 4.3 Utekelezaji

- **Tumia** `PrimaryButton` / `SecondaryButton` / `AccentButton` pale inapowezekana badala ya kujenga `ElevatedButton` ndani ya skrini.
- Ikiwa unahitaji “full width + loading + icon”, tumia widget hizo; ikiwa zina ukosefu (k.m. “danger” style), ongeza `DangerButton` kwenye `buttons.dart` na uitumie kwa “Futa” n.k.
- Kwa maandishi ya kitufe: theme ina `fontSize: 16`; ikiwa unataka 14 (kama `buttonLarge`), weka `textStyle: AppTextStyles.buttonLarge` kwenye style ya kitufe.

---

## 5. Spacing na radius

- **Padding ya skrini**: `AppSpacing.screenPadding` (horizontal 16, vertical 24) au `screenPaddingLarge` (24, 32).
- **Kati ya vitu**: `SizedBox(height: 8/16/24)` → tumia `AppSpacing.verticalSm/Md/Lg`.
- **Radius ya kadi / container**: `AppSpacing.borderRadiusLg` (16) au `borderRadiusXl` (24); epuka `BorderRadius.circular(20)` au `30` isipokuwa umeunda constant mpya kwenye `AppSpacing`.
- **Radius ya kitufe**: `AppSpacing.borderRadiusMd` (12) au `borderRadiusLg` (16).

Hii inasaidia “rhythm” ya layout iwe sawa kila skrini.

---

## 6. Mpango wa utekelezaji (Implement)

### Phase 1 – Rangi (kwa kipindi kifupi)

1. **Ongeza** rangi yoyote inayokosekana kwenye `AppColors` (k.m. `walletAccent` ikiwa unachagua Chaguo B).
2. **Badilisha** kila `Color(0xFF...)` kwenye skrini na widgets kuwa constant kutoka `AppColors`:
   - `0xFF1E293B` → `AppColors.textPrimary`
   - `0xFF64748B` → `AppColors.textSecondary`
   - `0xFF94A3B8` → `AppColors.textLight`
   - `0xFFF8FAFC` → `AppColors.background`
   - `0xFFF1F5F9` → `AppColors.surfaceLight`
   - `0xFFEF4444` → `AppColors.error`
   - `0xFF10B981` → `AppColors.success`
   - `0xFFF59E0B` / `0xFFF97316` → `AppColors.accent` (au `walletAccent` ikiwa umeongeza).
3. **Onyesha** mabadiliko kwenye: Login, Welcome, Client Home (tabs + cards), Worker Dashboard, Post Job, Edit Job, Payment Wait, Wallet, Withdrawal – halafu zingine.

### Phase 2 – Typography

1. **Onyesha** ukubwa wa font kwenye skrini:
   - Kichwa kikuu (splash, login title): `AppTextStyles.h1`.
   - Kichwa cha ukurasa: `AppTextStyles.h2` au `h3`.
   - Section titles: `AppTextStyles.h4` / `h5`.
   - Body: `AppTextStyles.bodyLarge` / `bodyMedium`.
   - Labels / hints: `AppTextStyles.labelLarge` / `caption`.
   - Bei: `AppTextStyles.price`.
2. **Ondoa** `TextStyle(fontSize: ..., fontWeight: ..., color: ...)` zilizo ndani ya `Text(...)` na ubadilishe kuwa `style: AppTextStyles.xxx` (na `.copyWith(color: ...)` ikiwa lazima).

### Phase 3 – Vitone na spacing

1. **Badilisha** vitone vilivyo ndani ya skrini kuwa `PrimaryButton` / `SecondaryButton` / `AccentButton` (au `DangerButton` ikiwa umeongeza).
2. **Thibitisha** ukubwa: `AppSpacing.buttonHeightMd` / `buttonHeightLg`, na radius kutoka `AppSpacing`.
3. **Standardize** padding za skrini: `AppSpacing.screenPadding` / `screenPaddingLarge` na `verticalMd` / `verticalLg` kati ya vitu.

### Phase 4 – Theme na accessibility

1. **Thibitisha** `AppTheme.lightTheme` inatumia `AppColors` na `AppTextStyles` (appBar, input, snackbar, bottom nav).
2. **Onyesha** `MediaQuery.textScaler` (tayari 0.8–1.2 kwenye `main.dart`) – hakikisha maandishi makubwa (h1, h2) hayavunjiki wakati font size ya kifaa iko juu.

---

## 7. Muhtasari wa “quick wins”

- **Rangi**: Replace `Color(0xFF...)` na `AppColors.xxx` kwenye skrini zote.
- **Font**: Replace inline `TextStyle` na `AppTextStyles.h1/h2/bodyLarge/price/caption` n.k.
- **Vitone**: Use `PrimaryButton`/`SecondaryButton`/`AccentButton` na `AppSpacing.buttonHeightMd/Lg`, `borderRadiusMd/Lg`.
- **Spacing**: Use `AppSpacing.screenPadding`, `verticalSm/Md/Lg`, `borderRadiusLg` kwa kadi.
- **Orange ya pesa**: Chagua moja – ama `AppColors.accent` kila mahali, ama `AppColors.walletAccent` kwenye `app_colors.dart` na uitumie tu wallet/withdraw.

Ukifuata hatua hizo, UI na UX ya app zitaenda sawa: **color combo**, **size za font na text**, na **vitone** vitakuwa na kiwango na rahisi kudumisha.

---

## 8. Utekelezaji uliofanywa (Implementation done)

- **AppSpacing**: `radius2xl` (30) na `borderRadius2xl` zimeongezwa.
- **AppColors**: `walletAccent`, `walletAccentDark`, `warningDark`, `splashDark`, `splashBackgroundGradient` zimeongezwa.
- **Vitone**: `DangerButton` imeongezwa kwenye `buttons.dart`; `PrimaryButton`/`SecondaryButton`/`AccentButton` zinatumia `AppTextStyles.buttonLarge`.
- **Rangi**: Hardcoded `Color(0xFF...)` zimebadilishwa kuwa `AppColors` kwenye skrini zote (auth, client, worker, chat, jobs, common, notification, settings, splash) na widgets (job_card, filter_modal, withdrawal_modal). Orange ya pesa: `AppColors.walletAccent` / `walletAccentDark` kwenye worker dashboard, wallet, withdrawal, job_card.
- **Typography**: Login, welcome, role_select zinatumia `AppTextStyles.h1`, `bodyLarge`, `labelLarge`, `link`, `caption`. Skrini nyingine zinaendelea kutumia inline `TextStyle`; unaweza kuzibadilisha hatua kwa hatua kuwa `AppTextStyles`.
- **Spacing**: Login inatumia `AppSpacing.screenPaddingLarge`, `verticalMd`, `horizontalSm`; welcome/role_select `AppSpacing.borderRadiusRound`, `borderRadiusLg`, `borderRadius2xl`.
- **Splash**: Gradient inatumia `AppColors.splashBackgroundGradient`.
- **Kumbuka**: `Colors.white` haikubadilishwa globali (ilikuwa na makosa kwenye nav icon); mahali pa maandishi/icon nyeupe kwenye rangi nyeusi tumia `AppColors.textWhite`.
