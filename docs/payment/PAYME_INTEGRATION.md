# Payme payment — UyDosh integration reference

This document is the **project-specific** checklist and architecture notes for integrating **Payme Business** (Uzbekistan). Official documentation lives on [Payme for Developers](https://developer.help.paycom.uz/). This file does not replace those pages — it maps them to our codebase and highlights differences vs [Click integration](./CLICK_INTEGRATION.md).

## Official documentation (entry points)

| Resource | URL |
|----------|-----|
| Developer portal | [developer.help.paycom.uz](https://developer.help.paycom.uz/) |
| **Merchant API — methods index** | [Методы Merchant API](https://developer.help.paycom.uz/metody-merchant-api/) |
| Protocol / interaction setup | Same site: «Протокол Merchant API», «Настройка взаимодействия», errors, data types |
| Subscribe API | Documented separately; interacts with Merchant API per Payme’s «Взаимодействие протоколов» |
| Mobile / Telegram / sandbox | Linked from the portal sidebar |

### Merchant API methods (from the index)

Use the linked pages for parameters, errors, and examples:

- **CheckPerformTransaction** — whether a payment may be created (`account`, amount, etc.).
- **CreateTransaction** — create a pending transaction (idempotent per Payme rules).
- **PerformTransaction** — complete the payment; where you confirm fulfillment eligibility.
- **CancelTransaction** — cancel / reverse according to state.
- **CheckTransaction** — query transaction state.
- **GetStatement** — merchant transaction list for a period.
- **SetFiscalData** — fiscal / receipt data when required.

Exact request/response shapes and **error codes** are only authoritative in Payme’s docs — follow them when implementing.

## Repositories

| Piece | Repository | Notes |
|--------|------------|--------|
| Merchant API endpoint (JSON-RPC handler) | `uydosh_backend` | Today: `POST /payments/payme/callback` is a **stub** — must implement Payme’s RPC contract. |
| Orders, amounts, gigs, AI SKUs | `uydosh_backend` | `paymentController.ts`, `paymentService.ts`, `gigService.ts`, `aiProductSkus.ts` |
| Client checkout | `uydosh_mobile` | Build Payme checkout URL per Payme «Инициализация платежей» + poll `GET /payments/orders/:id` |

## Quick facts (vs Click)

| Topic | Payme (typical Merchant API) | Click (SHOP API) |
|--------|------------------------------|------------------|
| Request format | **JSON-RPC** (Payme → your server) | **Form-urlencoded** fields |
| Amounts (UZS) | **Tyiyin** (1⁄100 so‘m), integer in API — aligns with our `payment` order amounts as integer | **So‘m** decimal string in SHOP API |
| Our doc | This file | [`CLICK_INTEGRATION.md`](./CLICK_INTEGRATION.md) |

Keep **one internal representation** for `payment_orders.amount` (e.g. tyiyin everywhere) and convert only at provider boundaries where the doc requires a different unit.

## Current UyDosh behavior (audit snapshot)

Re-verify in code before production.

- **Callback**: `POST /payments/payme/callback` uses **JSON** parsing — consistent with JSON-RPC payloads, but the handler **does not** dispatch `method` to **CheckPerformTransaction** / **CreateTransaction** / **PerformTransaction** / etc., and does not return a proper JSON-RPC **result** or **error**.
- **Security**: Callbacks are logged with `signatureValid: false` — Payme’s **Authorization** / signing rules from their docs must be implemented and verified on every request.
- **State machine**: `payment_orders` / `payment_transactions` are not updated from Payme responses yet; **PerformTransaction** success should map to `paid` and then call existing domain code (`grantPremiumFromPaidOrder`, `markBookingPaid`, etc.).
- **README**: May still describe callbacks as generic “raw JSON”; the real requirement is **JSON-RPC 2.0** semantics per Payme.

See also `uydosh_backend/SECURITY_TODO.md` (payment callback signing).

## Implementation checklist

### Backend

1. **Credentials**: Store Payme **merchant / cash register** identifiers and keys per Payme cabinet instructions ([Поиск ключа и id кассы](https://developer.help.paycom.uz/) in the portal). Never send the secret to the Flutter app.
2. **Single HTTP endpoint** exposed to Payme (`/payments/payme/callback` or the URL Payme expects after base path): accept **POST** with JSON body, parse **JSON-RPC**: `method`, `params`, `id`.
3. **Dispatch** to handlers for at least:
   - `CheckPerformTransaction`
   - `CreateTransaction`
   - `PerformTransaction`
   - `CancelTransaction`
   - `CheckTransaction`  
   Add **GetStatement** / **SetFiscalData** when your product scope needs them.
4. **Authorization**: Verify each request using Payme’s documented **Authorization** header / signing algorithm (exact scheme is on their site — implement from primary sources).
5. **Idempotency**: `CreateTransaction` / `PerformTransaction` may be retried; align with Payme’s idempotency and your `provider_transaction_id` / Payme `id`.
6. **Map `account` / order key**: Payme’s `account` (or equivalent in params) should resolve to `payment_orders` + `payment_transactions` rows you created when the user chose Payme.
7. **Responses**: Return valid **JSON-RPC 2.0** `result` or `error` objects as required by each method’s spec.
8. **After success**: For `gig_booking` / `ai_premium_month`, invoke the same fulfillment paths as for any verified paid order.

### API / mobile

1. **Initialize payment** using Payme’s «Инициализация платежей» (checkout URL / deep link pattern from current Payme docs).
2. Pass enough data in `merchant` payload / metadata so **CheckPerformTransaction** can validate amount and order id.
3. Poll **`GET /payments/orders/:id`** (authenticated) until `status` is terminal, or use return URL + refresh.

### Testing

1. Use Payme **sandbox** / test cabinet if available ([Песочница](https://developer.help.paycom.uz/) in the portal).
2. Unit tests: JSON-RPC router, signature verification (with test vectors from docs), duplicate **PerformTransaction**, canceled flow.

### Operations

1. Whitelist server IP if Payme requires it for production.
2. Monitor failed callbacks and Payme error codes — align dashboards with their **ERRORS** page.

## Optional / later

- **Subscribe API** — recurring payments; separate protocol tree on the same developer site.
- **Telegram bot**, **CMS plugins** — see portal «Телеграм бот», «Плагины для CMS».
- **Fiscalization**: **SetFiscalData** when mandatory for your goods.

## See also

- [`CLICK_INTEGRATION.md`](./CLICK_INTEGRATION.md) — Click SHOP API, so‘m vs tyiyin at boundaries.
- Payme **Merchant API methods**: [developer.help.paycom.uz — Методы Merchant API](https://developer.help.paycom.uz/metody-merchant-api/)

---

*Last updated: 2026-05-08. Update when Payme routes, signing, or amount rules change.*
