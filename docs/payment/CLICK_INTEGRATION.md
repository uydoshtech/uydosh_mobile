# Click payment — UyDosh integration reference

This document is the **project-specific** checklist and architecture notes for integrating [Click](https://docs.click.uz) (Uzbekistan). The verbatim official pages live next to this file under [`click_uz/`](./click_uz/) (`SKILL.md` + `references/`).

## Repositories

| Piece | Repository | Notes |
|--------|------------|--------|
| SHOP API callbacks, orders, signing | `uydosh_backend` | `paymentRoutes.ts`, `paymentController.ts`, `paymentService.ts` |
| Pay link / deep link from app | `uydosh_client` | Call backend for URL or fields, then `url_launcher` / WebView |
| Official protocol details | This repo | `docs/payment/click_uz/` |

## Quick facts (SHOP API + payment page)

| Item | Value |
|------|--------|
| User payment page | `https://my.click.uz/services/pay` (query params: `service_id`, `merchant_id`, `amount`, `transaction_param`, optional `return_url`, `card_type`) |
| SHOP API (Prepare / Complete) | HTTP **POST**, **`application/x-www-form-urlencoded`**, response body **JSON** |
| `sign_string` | **MD5** of concatenated fields **without separators** — use **constant-time** compare (`crypto.timingSafeEqual` in Node) |
| Amounts in SHOP API | **UZS in so‘m**, typically as decimal string (e.g. `1000.00`), **not** tiyin (contrast Payme) |
| Merchant cabinet | `https://merchant.click.uz` — set Prepare URL and Complete URL (often the **same** endpoint path) |
| Merchant API (optional) | `https://api.click.uz/v2/merchant/` — JSON + `Auth` header (different from SHOP API) |

Prepare hash:

`MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + amount + action + sign_time)` for `action = 0`.

Complete hash:

`MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + merchant_prepare_id + amount + action + sign_time)` for `action = 1`.

## Current UyDosh behavior (audit snapshot)

Use this as a gap list; re-verify in code before shipping.

- **Callbacks**: Routes may use **JSON** body parsing; Click sends **form-urlencoded**. Click-specific handler should use `express.urlencoded({ extended: false })`.
- **Handler logic**: Expect **Prepare** (`action = 0`) and **Complete** (`action = 1`) on one URL; verify `sign_string`, validate `service_id`, map `merchant_trans_id` to your order/transaction, enforce idempotency on `click_trans_id`, return required **JSON** fields per docs.
- **Orders API**: Internal amounts may be documented as **integer tiyin** for Payme-style flows; Click needs **so‘m** when building the payment URL and when comparing callback `amount`. Define one rule: e.g. store tiyin, convert to so‘m string only at Click boundaries.
- **Flutter**: Booking pay flow may only create an order via API; you still need to **open** `my.click.uz/...` (or embed **checkout.js** on web) with correct params.
- **Post-payment**: `GigService.markBookingPaid` / entitlements should run **after** verified Complete (`error = 0`), not from unauthenticated stub callbacks.

Official error ranges and edge cases are in `click_uz/references/02-shop-api-requests.md` and `03-shop-api-errors.md`.

## Implementation checklist

### Backend

1. **Environment**: `CLICK_SERVICE_ID`, `CLICK_MERCHANT_ID`, `CLICK_SECRET_KEY`; optional separate secrets for Merchant API later. Never expose `SECRET_KEY` to the client.
2. **Single callback route** for Click: `POST .../click/...` with **urlencoded** parser, raw body optional only if you implement sign from raw string (usually parse fields then rebuild concatenation per doc order).
3. **Prepare**: Find order by `merchant_trans_id` (your idempotency key), validate amount/currency, return JSON with `merchant_prepare_id` (stable integer; avoid unsafe truncation patterns).
4. **Complete**: Match `merchant_prepare_id`, handle `error` from Click, update `payment_orders` / `payment_transactions`, append **audit** (`click_paydoc_id` in payload — useful for support).
5. **Duplicate protection**: Same `click_trans_id` must not double-fulfill.
6. **Return JSON** even on merchant-side errors; follow docs for `error` codes (-1 … -9).
7. **Optional**: After successful Complete, call existing domain methods (e.g. gig booking accepted, AI entitlements).

### API surface for mobile / web

1. Either extend **create order** response or add a small endpoint that returns:
   - Full **payment URL**, or
   - Fields needed to build URL client-side (`service_id`, `merchant_id`, `amount` as **so‘m string**, `transaction_param` = your merchant transaction id).
2. **`transaction_param`**: Must round-trip to resolve the order on callback (often order id or UUID you already store on `payment_transactions`).

### Flutter client

1. Receive URL from API; open with **`url_launcher`** or in-app browser.
2. **`return_url`** (optional): HTTPS or app deep link as allowed by Click; resume polling `GET /payments/orders/:id` or return to booking screen.

### Testing

1. Use Click test tools / scenarios from `click_uz/references/04-shop-api-testing.md`.
2. Unit tests: `sign_string` computation, Prepare/Complete happy path, wrong sign, duplicate Complete, amount mismatch.

### Operations

1. **Static IP** for production server if required by Click; notify Click before IP changes.
2. **Firewall / whitelist** if not on TAS-IX (per Click checklist in `click_uz/SKILL.md`).
3. **Service activation** in merchant cabinet before live traffic.

## Optional later (out of minimal SHOP scope)

- **Merchant API**: invoices, reversal, payment status, card tokens — see `click_uz/references/08-merchant-api-requests.md`.
- **Fiscalization**: OFD / IKPU — `11-fiscalization.md`.
- **CLICK Pass** (QR POS): `10-click-pass.md`.
- **Telegram**: `12-telegram-payments.md`.
- **Inline checkout**: `06-inline-checkout.md` (`checkout.js`).

## File index (official mirror in this repo)

| File | Topic |
|------|--------|
| `click_uz/SKILL.md` | Overview, formulas, checklist |
| `click_uz/references/02-shop-api-requests.md` | Prepare / Complete specification |
| `click_uz/references/05-payment-button.md` | Payment URL / form |
| `click_uz/references/13-mobile-sdk.md` | Deep links, `return_url`, Android SDK |

## See also

- [`PAYME_INTEGRATION.md`](./PAYME_INTEGRATION.md) — Payme Business (JSON-RPC Merchant API, tyiyin amounts).

---

*Last updated: 2026-05-08. Update this file when callback routes or amount conventions change.*
