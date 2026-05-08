# Merchant API — Requests (Запросы)

> Source: https://docs.click.uz/merchant-api-request/

## Connection and Making Requests

### API Endpoint

```
https://api.click.uz/v2/merchant/
```

### Confidential Data

Upon registration, service provider receives:
- **merchant_id** — merchant identifier
- **service_id** — service identifier
- **merchant_user_id** — user identifier for API auth
- **secret_key** — secret key for digest generation

> **WARNING**: secret_key is a confidential parameter. The service provider is fully responsible for its safety. Exposing secret_key may compromise your data.

### Authentication

HTTP Header:
```
Auth: merchant_user_id:digest:timestamp
```

- **digest** = `SHA1(timestamp + secret_key)`
- **timestamp** = UNIX timestamp (10-digit seconds from epoch start)

### Required Headers

```
Accept: application/json
Auth: {merchant_user_id}:{digest}:{timestamp}
Content-Type: application/json
```

### Supported Content Types

- `application/json`
- `application/xml`

### Authentication Code Examples

**Node.js:**
```javascript
const crypto = require('crypto');

function getClickAuthHeader(merchantUserId, secretKey) {
  const timestamp = Math.floor(Date.now() / 1000);
  const digest = crypto.createHash('sha1')
    .update(`${timestamp}${secretKey}`)
    .digest('hex');
  return `${merchantUserId}:${digest}:${timestamp}`;
}
```

**Go:**
```go
func getClickAuthHeader(merchantUserID, secretKey string) string {
    timestamp := time.Now().Unix()
    h := sha1.New()
    h.Write([]byte(fmt.Sprintf("%d%s", timestamp, secretKey)))
    digest := fmt.Sprintf("%x", h.Sum(nil))
    return fmt.Sprintf("%s:%s:%d", merchantUserID, digest, timestamp)
}
```

---

## 1. Create Invoice (Создать инвойс)

### Request

```http
POST https://api.click.uz/v2/merchant/invoice/create HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "amount": 50000.00,
  "phone_number": "998901234567",
  "merchant_trans_id": "order_123"
}
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | amount | float | Payment amount (in so'm) |
| 3 | phone_number | string | Invoice receiver phone number |
| 4 | merchant_trans_id | string | Order ID / personal account / login in billing |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "invoice_id": 1234567
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code (0 = success) |
| 2 | error_note | string | Error description |
| 3 | invoice_id | bigint | Created invoice ID |

---

## 2. Check Invoice Status (Проверка статуса инвойса)

### Request

```http
GET https://api.click.uz/v2/merchant/invoice/status/:service_id/:invoice_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "invoice_status": -99,
  "invoice_status_note": "Deleted"
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | invoice_status | bigint | Invoice status code |
| 4 | invoice_status_note | string | Status description |

### Invoice Status Codes

| Status | Description |
|--------|-------------|
| -99 | Deleted |
| 0 | Pending |
| 1 | Paid |

---

## 3. Check Payment Status (by payment_id)

### Request

```http
GET https://api.click.uz/v2/merchant/payment/status/:service_id/:payment_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | payment_id | bigint | Payment ID |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "payment_id": 1234567,
  "payment_status": 1
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | payment_id | bigint | Payment ID |
| 4 | payment_status | integer | Payment status code |

---

## 4. Check Payment Status (by merchant_trans_id)

### Request

```http
GET https://api.click.uz/v2/merchant/payment/status_by_mti/:service_id/:merchant_trans_id/:YYYY-MM-DD HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | merchant_trans_id | string | Merchant transaction identifier |
| 3 | YYYY-MM-DD | string | Day when payment was created |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "payment_id": 1234567,
  "merchant_trans_id": "user123"
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | payment_id | bigint | Payment ID |
| 4 | payment_status | int | Payment status code |

---

## 5. Payment Reversal / Cancel (Снятие платежа)

### Request

```http
DELETE https://api.click.uz/v2/merchant/payment/reversal/:service_id/:payment_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | payment_id | bigint | Payment ID |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "payment_id": 1234567
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | payment_id | bigint | Payment ID |

### Reversal Conditions

- Payment must have been completed successfully
- Only payments created in the **current reporting month** can be reversed
- Payments from the previous month can only be cancelled on the **first day** of the current month
- Payment must have been made with an online card
- Payment reversal may be rejected due to refusal by **UZCARD**

---

## 6. Create Card Token (Создание токена карты)

### Request

```http
POST https://api.click.uz/v2/merchant/card_token/request HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "card_number": "8600123456789012",
  "expire_date": "0399",
  "temporary": 1
}
```

`temporary` — create token for one-time use. Temporary tokens are automatically removed after payment.

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | card_number | string | Full card number |
| 3 | expire_date | string | Card expiry date (format: MMYY) |
| 4 | temporary | bit | 0 = reusable token, 1 = single-use token |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "card_token": "3B1DF3F1-7358-407C-B57F-0F6351310803",
  "phone_number": "99890***1234",
  "temporary": 1
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | card_token | string | Card token (UUID format) |
| 4 | phone_number | string | User phone number (masked) |
| 5 | temporary | bit | Type of created token |

---

## 7. Verify Card Token (Подтверждение токена карты)

### Request

```http
POST https://api.click.uz/v2/merchant/card_token/verify HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "card_token": "3B1DF3F1-7358-407C-B57F-0F6351310803",
  "sms_code": 123456
}
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | card_token | string | Card token from step 6 |
| 3 | sms_code | int | SMS verification code received by user |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "card_number": "8600 55** **** 3244"
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | card_number | string | Masked card number |

---

## 8. Payment with Token (Оплата с помощью токена)

### Request

```http
POST https://api.click.uz/v2/merchant/card_token/payment HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "card_token": "3B1DF3F1-7358-407C-B57F-0F6351310803",
  "amount": 50000.00,
  "transaction_parameter": "order_123"
}
```

`transaction_parameter` — user or contract identifier on merchant billing

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | card_token | string | Verified card token |
| 3 | amount | float | Payment amount (in so'm) |
| 4 | transaction_parameter | string | Order/account ID (maps to merchant_trans_id) |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success",
  "payment_id": "598761234",
  "payment_status": 1
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | error_code | integer | Error code |
| 2 | error_note | string | Error description |
| 3 | payment_id | bigint | Payment ID |
| 4 | payment_status | int | Payment status code |

---

## 9. Delete Card Token (Удаление токена карты)

### Request

```http
DELETE https://api.click.uz/v2/merchant/card_token/:service_id/:card_token HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | card_token | string | Card token to delete |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success"
}
```

---

## Full Merchant API Client (Node.js)

```javascript
const crypto = require('crypto');

class ClickMerchantAPI {
  constructor({ merchantUserId, serviceId, secretKey }) {
    this.merchantUserId = merchantUserId;
    this.serviceId = serviceId;
    this.secretKey = secretKey;
    this.baseUrl = 'https://api.click.uz/v2/merchant';
  }

  getAuthHeader() {
    const timestamp = Math.floor(Date.now() / 1000);
    const digest = crypto.createHash('sha1')
      .update(`${timestamp}${this.secretKey}`)
      .digest('hex');
    return `${this.merchantUserId}:${digest}:${timestamp}`;
  }

  async request(method, path, body = null) {
    const options = {
      method,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Auth': this.getAuthHeader()
      }
    };
    if (body) options.body = JSON.stringify(body);
    const res = await fetch(`${this.baseUrl}${path}`, options);
    return res.json();
  }

  async createInvoice(amount, phoneNumber, merchantTransId) {
    return this.request('POST', '/invoice/create', {
      service_id: this.serviceId, amount, phone_number: phoneNumber, merchant_trans_id: merchantTransId
    });
  }

  async checkInvoiceStatus(invoiceId) {
    return this.request('GET', `/invoice/status/${this.serviceId}/${invoiceId}`);
  }

  async checkPaymentStatus(paymentId) {
    return this.request('GET', `/payment/status/${this.serviceId}/${paymentId}`);
  }

  async checkPaymentByMTI(merchantTransId, date) {
    return this.request('GET', `/payment/status_by_mti/${this.serviceId}/${merchantTransId}/${date}`);
  }

  async reversePayment(paymentId) {
    return this.request('DELETE', `/payment/reversal/${this.serviceId}/${paymentId}`);
  }

  async requestCardToken(cardNumber, expireDate, temporary = 1) {
    return this.request('POST', '/card_token/request', {
      service_id: this.serviceId, card_number: cardNumber, expire_date: expireDate, temporary
    });
  }

  async verifyCardToken(cardToken, smsCode) {
    return this.request('POST', '/card_token/verify', {
      service_id: this.serviceId, card_token: cardToken, sms_code: smsCode
    });
  }

  async payWithToken(cardToken, amount, merchantTransId) {
    return this.request('POST', '/card_token/payment', {
      service_id: this.serviceId, card_token: cardToken, amount, transaction_parameter: merchantTransId
    });
  }

  async deleteCardToken(cardToken) {
    return this.request('DELETE', `/card_token/${this.serviceId}/${cardToken}`);
  }
}
```
