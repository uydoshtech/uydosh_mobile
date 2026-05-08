# CLICK Pass — QR-Code POS Payments

> Source: https://docs.click.uz/click-pass/

## Overview

CLICK Pass enables offline/POS payments via QR code. User shows QR in Click app, merchant scans it, payment processed via Merchant API.

**API Endpoint**: `https://api.click.uz/v2/merchant/`
**Auth**: Same as Merchant API (`Auth: merchant_user_id:digest:timestamp`)

## Payment Status Codes

| Code | Description |
|------|-------------|
| < 0 | Error (details in error_note) |
| 0 | Payment created |
| 1 | Processing |
| 2 | Successful payment |

---

## 1. Make Payment (Оплата с помощью CLICK Pass)

### Request

```http
POST https://api.click.uz/v2/merchant/click_pass/payment HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "otp_data": "1234567415821",
  "amount": 500,
  "cashbox_code": "KASSA-1",
  "transaction_id": "12345"
}
```

### Request Parameters

| # | Parameter | Type | Required | Description |
|---|-----------|------|----------|-------------|
| 1 | service_id | integer | Yes | Service ID |
| 2 | otp_data | string | Yes | Content of QR code from user's Click app |
| 3 | amount | float | Yes | Payment amount in so'm |
| 4 | cashbox_code | string | No | Cashbox/terminal identifier |
| 5 | transaction_id | string | No | Your transaction ID |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "payment_id": 1234567,
  "payment_status": 1,
  "confirm_mode": 1,
  "card_type": "private",
  "processing_type": "UZCARD",
  "card_number": "860002******8331",
  "phone_number": "998221234567"
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code (0 = success) |
| 2 | error_note | string | Error description |
| 3 | payment_id | bigint | Click payment ID |
| 4 | payment_status | int | Payment status code |
| 5 | confirm_mode | bit | 1 = must confirm within 30 seconds |
| 6 | card_type | string | `private` (personal) or `corporate` (business) |
| 7 | processing_type | string | `UZCARD`, `HUMO`, or `WALLET` (Click wallet) |
| 8 | card_number | string | Masked card number |
| 9 | phone_number | string | User's phone number |

---

## 2. Check Payment Status

```http
GET https://api.click.uz/v2/merchant/payment/status/:service_id/:payment_id HTTP/1.1
```

Same as standard Merchant API payment status check (see 08-merchant-api-requests.md).

---

## 3. Payment Reversal (Cancel)

```http
DELETE https://api.click.uz/v2/merchant/payment/reversal/:service_id/:payment_id HTTP/1.1
```

Same conditions as standard Merchant API reversal.

---

## 4. Confirm Payment (Подтверждение оплаты)

**Required only when `confirm_mode = 1`** in payment response.

### Request

```http
POST https://api.click.uz/v2/merchant/click_pass/confirm HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "payment_id": 1234567
}
```

### Response

```json
{
  "error_code": 0,
  "error_note": "Платеж подтвержден"
}
```

> **IMPORTANT**: Unconfirmed payments are automatically cancelled after **30 seconds**.

---

## 5. Enable Confirmation Mode (Включение режима подтверждения)

Turns on confirm mode for a service. ALL Click Pass payments will require explicit confirmation.

### Request

```http
PUT https://api.click.uz/v2/merchant/click_pass/confirmation/:service_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Response

```json
{
  "error_code": 0,
  "error_note": "Режим подтверждения включен"
}
```

---

## 6. Disable Confirmation Mode (Отключение режима подтверждения)

### Request

```http
DELETE https://api.click.uz/v2/merchant/click_pass/confirmation/:service_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Response

```json
{
  "error_code": 0,
  "error_note": "Режим подтверждения выключен"
}
```

## Confirmation Mode Notes

- Confirmation mode is enabled per **service_id** — affects ALL Click Pass payments for that service
- When enabled, every payment must be confirmed immediately after receiving a successful response
- **30 second timeout** — unconfirmed payments are auto-cancelled
- Use `PUT .../click_pass/confirmation/:service_id` to enable
- Use `DELETE .../click_pass/confirmation/:service_id` to disable
