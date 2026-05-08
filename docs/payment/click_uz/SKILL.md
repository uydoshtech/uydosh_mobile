---
name: click-integration
description: >
  Expert-level Click payment integration skill for Uzbekistan's Click SuperApp.
  Use whenever user mentions Click, click.uz, SHOP API, Merchant API, Click to'lov,
  Click integratsiya, Click callback, prepare/complete, click_trans_id, merchant_trans_id,
  Click fiscalization, Click button, Click invoice, card token, Click Pass, checkout.js,
  createPaymentRequest, Click Telegram, mobile SDK, merchant.click.uz, my.click.uz,
  api.click.uz, or Click error codes (-1 to -9). Covers SHOP API (Prepare/Complete),
  Merchant API (invoices, payments, tokens, reversal), payment button, inline checkout,
  CLICK Pass (QR POS), fiscalization (OFD/IKPU), Telegram bot payments, mobile SDK,
  CMS plugins (WooCommerce, OpenCart, 1C-Bitrix), testing, and deployment.
  Trigger for partial mentions like "click", "shop api", "click payment", "click pass",
  "click telegram", "click plugin" in Uzbek, Russian, or English.
---

# Click Payment Integration — Expert Guide

This skill makes you a **super-expert** on Click payment system integration in Uzbekistan. Every page from docs.click.uz is captured in the reference files below — nothing is cut or summarized.

## Quick Reference

| Item | Value |
|------|-------|
| Payment page URL | `https://my.click.uz/services/pay` |
| Merchant API endpoint | `https://api.click.uz/v2/merchant/` |
| Merchant cabinet | `https://merchant.click.uz` |
| Documentation | `https://docs.click.uz` |
| SHOP API Protocol | HTTP/HTTPS POST, `application/x-www-form-urlencoded` |
| Merchant API Protocol | HTTPS, `application/json` (also supports `application/xml`) |
| Currency | UZS, amounts in **so'm** (NOT tiyin — unlike Payme!) |
| Amount format | float with 2 decimal places (e.g., `1000.00`) |
| SHOP API auth | MD5 sign_string hash |
| Merchant API auth | SHA1 digest in `Auth` header |
| Checkout.js CDN | `https://my.click.uz/pay/checkout.js` |
| Android SDK | `https://github.com/click-llc/android-msdk` |

## Choosing the Right Integration Method

Click offers **multiple** ways to accept payments. Read the appropriate reference file for full details.

### 1. SHOP API — "Click calls YOUR server" (most common)
- User pays via Click → Click sends Prepare/Complete to your server
- You implement 1 callback endpoint handling 2 actions
- **Read**: `references/02-shop-api-requests.md`

### 2. Payment Button/Link — "Redirect user to Click"
- Simple link/form redirects user to my.click.uz payment page
- Works with SHOP API callback on your server
- **Read**: `references/05-payment-button.md`

### 3. Inline Checkout — "Pay on YOUR site without redirect"
- Embed `checkout.js` widget — payment form opens as overlay
- No redirect to my.click.uz needed
- **Read**: `references/06-inline-checkout.md`

### 4. Merchant API — "YOU call Click's server"
- Create invoices, check payment status, refund, card tokens
- Supplements SHOP API, not a replacement
- **Read**: `references/08-merchant-api-requests.md`

### 5. CLICK Pass — "QR-code POS payment"
- Merchant scans QR from user's Click app
- For physical retail, kiosks
- **Read**: `references/10-click-pass.md`

### 6. Telegram Bot Payments
- Accept payments inside Telegram via Click provider
- Uses Telegram Bot API with Click provider_token
- **Read**: `references/12-telegram-payments.md`

### 7. Mobile SDK / Deep Links
- Android SDK library or deep link integration (Android + iOS)
- **Read**: `references/13-mobile-sdk.md`

### Decision Matrix

| Method | Who initiates | Where user pays | Best for |
|--------|--------------|-----------------|----------|
| SHOP API + Payment Button | User clicks link | Click web/app | E-commerce, web |
| SHOP API + Inline Checkout | User on your site | Overlay on your site | SPA, custom UX |
| Merchant API Invoice | Merchant sends invoice | User confirms in Click app | Subscriptions, push billing |
| Merchant API Card Token | Merchant charges token | No user interaction | Recurring, card-on-file |
| CLICK Pass | Merchant scans QR | Already in Click app | Physical retail, POS |
| Telegram Payments | User in Telegram | Telegram payment UI | Telegram bots |
| Mobile SDK / Deep Link | User in your app | Click app or browser | Mobile apps |

## Sign String Formulas (SHOP API)

| Request | Formula |
|---------|---------|
| Prepare (action=0) | `MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + amount + action + sign_time)` |
| Complete (action=1) | `MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + merchant_prepare_id + amount + action + sign_time)` |

**CRITICAL**: Parameters concatenated WITHOUT separators. Use constant-time comparison (e.g., `crypto.timingSafeEqual`).

## Merchant API Authentication

```
Auth: {merchant_user_id}:{digest}:{timestamp}
```
- `digest` = `SHA1(timestamp + secret_key)`
- `timestamp` = UNIX timestamp (10-digit seconds)

## Error Codes Summary (SHOP API)

| error | error_note | Description |
|-------|------------|-------------|
| 0 | Success | OK |
| -1 | SIGN CHECK FAILED! | Signature verification failed |
| -2 | Incorrect parameter amount | Wrong amount |
| -3 | Action not found | Unknown action |
| -4 | Already paid | Duplicate payment |
| -5 | User does not exist | Order/user not found |
| -6 | Transaction does not exist | Payment record not found |
| -7 | Failed to update user | DB/balance update error |
| -8 | Error in request from click | Malformed request |
| -9 | Transaction cancelled | Previously cancelled |

## Merchant API HTTP Error Codes

| Code | Description |
|------|-------------|
| 200, 201 | OK |
| 400 | Bad request (malformed data or URI) |
| 401 | Not authorized (auth error) |
| 403 | Forbidden (method not allowed) |
| 404 | Not found (method not found) |
| 406 | Not acceptable (invalid data type) |
| 410 | Gone (deprecated method) |
| 500 | Internal server error |
| 502 | Service is down or being upgraded |

## Before You Start — Setup Checklist

1. Register with Click and sign contract with connected bank
2. Receive credentials: `merchant_id`, `service_id`, `SECRET_KEY`, `merchant_user_id`
3. Get access to merchant cabinet at `merchant.click.uz`
4. Set **Prepare URL** and **Complete URL** in merchant cabinet → Сервисы → pencil icon
5. Request service activation from Click support (disabled by default!)
6. If NOT on TAS-IX: provide domain + IP + port for firewall whitelisting
7. Static IP required — notify Click before changing

## Critical Implementation Rules

1. **Single callback endpoint** — one URL for both Prepare (action=0) and Complete (action=1)
2. **Content-Type is form-urlencoded** — SHOP API sends `application/x-www-form-urlencoded`, NOT JSON
3. **Amounts in SO'M** — NOT tiyin! Float format: `50000.00`
4. **Always verify sign_string** with constant-time comparison
5. **Check `error` field in requests** — if Click sends error ≤ -1, respond with error -9
6. **Protect against duplicate click_trans_id** processing
7. **Verify merchant_prepare_id** in Complete matches Prepare record
8. **Complete error=0 → fulfill order; error<0 → cancel order**
9. **Fiscalization mandatory** for more than 1 IKPU code
10. **Service must be activated** by Click support before real payments
11. **IP must be static** — notify Click before any change
12. **Log click_paydoc_id** — shown in user's SMS, needed for support queries

## Common Gotchas

- **Callback URLs must be publicly accessible** — `localhost` won't work in production
- **Prepare URL validation** — merchant cabinet validates format; must be valid HTTPS URL
- **sign_string concatenation** — NO separators between params
- **merchant_prepare_id overflow** — use proper integer, `Date.now() % 2147483647` causes collisions
- **Response must always be JSON** with all required fields, even on error
- **After successful Complete (error=0)** — response CANNOT be error (except -4 or -9)
- **If fulfillment fails after successful Complete** — respond success, then cancel via Merchant API reversal

## Reference Files — Complete docs.click.uz Mirror

Each file corresponds 1:1 to a docs.click.uz page. Nothing is cut.

### SHOP API
- `references/01-shop-api-overview.md` — General provisions, terms, flow diagram
- `references/02-shop-api-requests.md` — Prepare & Complete full spec with code examples
- `references/03-shop-api-errors.md` — All error codes (Click-side and merchant-side)
- `references/04-shop-api-testing.md` — Testing software, scenarios, report generation

### Payment Integration
- `references/05-payment-button.md` — Payment link URL and HTML form (with redirect)
- `references/06-inline-checkout.md` — checkout.js widget, createPaymentRequest() JS API

### Merchant API
- `references/07-merchant-api-overview.md` — General provisions, terms, flow diagram, contract info
- `references/08-merchant-api-requests.md` — All endpoints: invoice, payment status, reversal, card token
- `references/09-merchant-api-errors.md` — HTTP status codes

### Additional
- `references/10-click-pass.md` — QR-code POS payments, confirm mode
- `references/11-fiscalization.md` — OFD submit_items, submit_qrcode, get fiscal data
- `references/12-telegram-payments.md` — Bot setup, sendInvoice, pre_checkout_query, live mode
- `references/13-mobile-sdk.md` — Android SDK, iOS deep links, return_url handling
- `references/14-server-examples.md` — Official PHP, Django repos + community Node.js/TypeScript
- `references/15-cms-plugins.md` — WooCommerce, OpenCart, Drupal, 1C-Bitrix, Joomla, CS-Cart
