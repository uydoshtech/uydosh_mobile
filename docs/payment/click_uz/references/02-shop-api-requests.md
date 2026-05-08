# SHOP API — Requests (Prepare & Complete)

> Source: https://docs.click.uz/click-api-request/

## Description of Interaction

Interaction is via the API-interface on the supplier's server. API-interface shall fully comply with this document. Payment created in CLICK system is transmitted over **HTTP (HTTPS)** by the **POST** method to the API-interface of the supplier. Supplier provides CLICK system with URL-addresses for interaction with the API-interface.

Interaction is divided into two stages:
1. **Prepare** (action=0)
2. **Complete** (action=1)

---

## Prepare Request (action=0)

Preparation and verification of payment.

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | click_trans_id | bigint | ID of transaction (iteration) in CLICK system, i.e. attempt to make a payment |
| 2 | service_id | int | ID of the service |
| 3 | click_paydoc_id | bigint | Payment number in CLICK system. Displayed to the customer in SMS when paying |
| 4 | merchant_trans_id | varchar | Order ID (for online shops) / personal account / login in the billing of the supplier |
| 5 | amount | float | Payment amount (in soums) |
| 6 | action | int | Action to perform. **0** for Prepare |
| 7 | error | int | Status code. 0 = success. In case of error returns error code |
| 8 | error_note | varchar | Description of the payment status code |
| 9 | sign_time | varchar | Payment date. Format: `YYYY-MM-DD HH:mm:ss` |
| 10 | sign_string | varchar | Verification hash: `MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + amount + action + sign_time)`. SECRET_KEY is a unique string issued to supplier when connecting |

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | click_trans_id | bigint | Payment ID in CLICK system |
| 2 | merchant_trans_id | varchar | Order ID / personal account / login in billing |
| 3 | merchant_prepare_id | int | Payment ID in the billing system of the supplier for confirmation |
| 4 | error | int | Status code. 0 = success. Negative = error code |
| 5 | error_note | varchar | Description of payment status |

### Prepare Validation Logic

CLICK system checks the payment options (merchant_trans_id, amount) with this request:

**a.** Presence of the formed order/login/personal account number in the billing system of the supplier, its actuality, and the ability of the supplier to supply the product or service specified in the order.

> **IMPORTANT**: For online shopping, when receiving a request the supplier should reserve the appropriate product for the indicated order number, to prevent "interception" by other customers and purchase of the same product by several customers.

**b.** The actuality of the order amount or payment.

### Prepare Response Scenarios

**a. Order is valid, payment pending** — Upon receiving this status, the Complete request will be sent by CLICK.

**b. Order is invalid/cancelled** — Upon receiving this status, Complete request with cancellation indication will be sent by CLICK.

> **NOTE**: Upon receiving a negative response from the supplier, if funds have already been written off from the user's account (request was given repetitively because CLICK did not wait for reply to previous Complete and doesn't know order status), then CLICK will give a Complete request with confirmation of payment. If funds are not charged, CLICK also cancels the payment.

**c. Order was previously confirmed** — Payment will be completed. Complete request will NOT be sent repetitively.

> **NOTE**: The supplier MUST protect against repetitive payment for a previously confirmed payment with the same click_trans_id.

---

## Complete Request (action=1)

Completion of the payment.

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | click_trans_id | bigint | Payment ID in CLICK system |
| 2 | service_id | int | ID of the service |
| 3 | click_paydoc_id | bigint | Payment number in CLICK system. Displayed in SMS |
| 4 | merchant_trans_id | varchar | Order ID / personal account / login in billing |
| 5 | merchant_prepare_id | int | Payment ID in billing system, received in Prepare response |
| 6 | amount | float | Payment amount (in soums) |
| 7 | action | int | Action to perform. **1** for Complete |
| 8 | error | int | Status code. **0** = funds deducted successfully. **≤ -1** = error/cancellation |
| 9 | error_note | varchar | Description of payment status |
| 10 | sign_time | varchar | Payment date. Format: `YYYY-MM-DD HH:mm:ss` |
| 11 | sign_string | varchar | Verification hash: `MD5(click_trans_id + service_id + SECRET_KEY + merchant_trans_id + merchant_prepare_id + amount + action + sign_time)` |

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | click_trans_id | bigint | Payment ID in CLICK system |
| 2 | merchant_trans_id | varchar | Order ID / personal account / login in billing |
| 3 | merchant_confirm_id | int | Transaction ID to complete payment in billing (may be NULL) |
| 4 | error | int | Status code. 0 = success. Negative = error code |
| 5 | error_note | varchar | Description of payment status |

### Complete Behavior

This request completes the on-line payment process. Upon receiving positive response from supplier on Prepare, CLICK checks the possibility of payment by the user.

**Depending on the success of writing off amounts, Complete request contains error parameter:**

1. `error = 0` — **Successfully**. Sent when funds are written off successfully. Supplier MUST supply goods or render the paid service.

2. `error ≤ -1` — **Cancel**. Sent in case of writing off error or other error. Supplier MUST:
   - Remove reservation (if any) from the products
   - Return response with error code **-9** (transaction cancelled)
   - In case of cancellation by CLICK, an error description will also be sent

> **IMPORTANT**: If the response to Prepare and withdrawal of funds from card are successful, the response to Complete **CANNOT be an error** (unless payment was previously confirmed error=-4 or second attempt to confirm previously canceled payment error=-9). Upon receiving error response from vendor after several attempts, the payment will hang for manual investigation by CLICK technical support.

> **IMPORTANT**: If an error occurred in provision of services/sales after successful withdrawal of funds from card during execution of Complete, the vendor's billing responds to Complete "successfully" and sends a request for "cancellation of payment" (see Merchant API Payment_cancel / reversal).

---

## Implementation Examples

### Node.js / Express

```javascript
const crypto = require('crypto');
const express = require('express');
const app = express();

// CRITICAL: SHOP API sends form-urlencoded, NOT JSON
app.use(express.urlencoded({ extended: true }));

const CLICK_SECRET_KEY = process.env.CLICK_SECRET_KEY;
const CLICK_SERVICE_ID = parseInt(process.env.CLICK_SERVICE_ID);

app.post('/api/payment/click/callback', async (req, res) => {
  const {
    click_trans_id, service_id, click_paydoc_id,
    merchant_trans_id, merchant_prepare_id,
    amount, action, error, error_note,
    sign_time, sign_string
  } = req.body;

  const actionInt = parseInt(action);

  // 1. Verify sign_string
  let signSource;
  if (actionInt === 0) {
    signSource = `${click_trans_id}${service_id}${CLICK_SECRET_KEY}${merchant_trans_id}${amount}${action}${sign_time}`;
  } else if (actionInt === 1) {
    signSource = `${click_trans_id}${service_id}${CLICK_SECRET_KEY}${merchant_trans_id}${merchant_prepare_id}${amount}${action}${sign_time}`;
  } else {
    return res.json({ error: -3, error_note: 'Action not found' });
  }

  const expectedSign = crypto.createHash('md5').update(signSource).digest('hex');

  // Constant-time comparison to prevent timing attacks
  const signBuf = Buffer.from(sign_string || '');
  const expectedBuf = Buffer.from(expectedSign);
  if (signBuf.length !== expectedBuf.length || !crypto.timingSafeEqual(signBuf, expectedBuf)) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -1,
      error_note: 'SIGN CHECK FAILED!'
    });
  }

  // 2. Validate service_id
  if (parseInt(service_id) !== CLICK_SERVICE_ID) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -8,
      error_note: 'Error in request from click'
    });
  }

  // 3. Route to handler
  if (actionInt === 0) {
    return handlePrepare(req.body, res);
  } else {
    return handleComplete(req.body, res);
  }
});

async function handlePrepare(params, res) {
  const { click_trans_id, merchant_trans_id, amount, error: clickError } = params;

  // Check if Click sent an error
  if (parseInt(clickError) < 0) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -9,
      error_note: 'Transaction cancelled'
    });
  }

  // Find order by merchant_trans_id
  const order = await Order.findById(merchant_trans_id);
  if (!order) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -5,
      error_note: 'User does not exist'
    });
  }

  // Verify amount
  if (Math.abs(parseFloat(amount) - order.amount) > 0.01) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -2,
      error_note: 'Incorrect parameter amount'
    });
  }

  // Check if already paid
  if (order.status === 'paid') {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -4,
      error_note: 'Already paid'
    });
  }

  // Check if cancelled
  if (order.status === 'cancelled') {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_prepare_id: 0,
      error: -9,
      error_note: 'Transaction cancelled'
    });
  }

  // Create payment record (reserve the order)
  const payment = await Payment.create({
    click_trans_id: parseInt(click_trans_id),
    click_paydoc_id: parseInt(params.click_paydoc_id),
    merchant_trans_id,
    amount: parseFloat(amount),
    status: 'preparing'
  });

  return res.json({
    click_trans_id: parseInt(click_trans_id),
    merchant_trans_id,
    merchant_prepare_id: payment.id,
    error: 0,
    error_note: 'Success'
  });
}

async function handleComplete(params, res) {
  const {
    click_trans_id, merchant_trans_id, merchant_prepare_id,
    amount, error: clickError, click_paydoc_id
  } = params;

  // Find payment record by merchant_prepare_id
  const payment = await Payment.findById(parseInt(merchant_prepare_id));
  if (!payment) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -6,
      error_note: 'Transaction does not exist'
    });
  }

  // Verify merchant_prepare_id belongs to this merchant_trans_id
  if (payment.merchant_trans_id !== merchant_trans_id) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -6,
      error_note: 'Transaction does not exist'
    });
  }

  // If Click reports error — cancel
  if (parseInt(clickError) < 0) {
    await payment.update({ status: 'cancelled' });
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -9,
      error_note: 'Transaction cancelled'
    });
  }

  // Check if already paid (idempotency)
  if (payment.status === 'paid') {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: payment.id,
      error: -4,
      error_note: 'Already paid'
    });
  }

  // Check if previously cancelled
  if (payment.status === 'cancelled') {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -9,
      error_note: 'Transaction cancelled'
    });
  }

  // Verify amount
  if (Math.abs(parseFloat(amount) - payment.amount) > 0.01) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -2,
      error_note: 'Incorrect parameter amount'
    });
  }

  // ATOMIC: Mark as paid + fulfill order
  try {
    await db.transaction(async (tx) => {
      await payment.update({ status: 'paid', click_paydoc_id: parseInt(click_paydoc_id) }, { transaction: tx });
      await fulfillOrder(merchant_trans_id, { transaction: tx });
    });
  } catch (err) {
    return res.json({
      click_trans_id: parseInt(click_trans_id),
      merchant_trans_id,
      merchant_confirm_id: null,
      error: -7,
      error_note: 'Failed to update user'
    });
  }

  return res.json({
    click_trans_id: parseInt(click_trans_id),
    merchant_trans_id,
    merchant_confirm_id: payment.id,
    error: 0,
    error_note: 'Success'
  });
}
```

### Go

```go
package click

import (
    "crypto/md5"
    "crypto/subtle"
    "encoding/hex"
    "encoding/json"
    "fmt"
    "net/http"
    "strconv"
)

type ClickCallback struct {
    ClickTransID     string `form:"click_trans_id"`
    ServiceID        string `form:"service_id"`
    ClickPaydocID    string `form:"click_paydoc_id"`
    MerchantTransID  string `form:"merchant_trans_id"`
    MerchantPrepareID string `form:"merchant_prepare_id"`
    Amount           string `form:"amount"`
    Action           string `form:"action"`
    Error            string `form:"error"`
    ErrorNote        string `form:"error_note"`
    SignTime         string `form:"sign_time"`
    SignString       string `form:"sign_string"`
}

func ClickCallbackHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        respondJSON(w, map[string]interface{}{"error": -3, "error_note": "Method not allowed"})
        return
    }

    r.ParseForm()

    cb := ClickCallback{
        ClickTransID:      r.FormValue("click_trans_id"),
        ServiceID:         r.FormValue("service_id"),
        ClickPaydocID:     r.FormValue("click_paydoc_id"),
        MerchantTransID:   r.FormValue("merchant_trans_id"),
        MerchantPrepareID: r.FormValue("merchant_prepare_id"),
        Amount:            r.FormValue("amount"),
        Action:            r.FormValue("action"),
        Error:             r.FormValue("error"),
        ErrorNote:         r.FormValue("error_note"),
        SignTime:          r.FormValue("sign_time"),
        SignString:        r.FormValue("sign_string"),
    }

    // Build sign source
    var signSource string
    if cb.Action == "0" {
        signSource = fmt.Sprintf("%s%s%s%s%s%s%s",
            cb.ClickTransID, cb.ServiceID, secretKey,
            cb.MerchantTransID, cb.Amount, cb.Action, cb.SignTime)
    } else if cb.Action == "1" {
        signSource = fmt.Sprintf("%s%s%s%s%s%s%s%s",
            cb.ClickTransID, cb.ServiceID, secretKey,
            cb.MerchantTransID, cb.MerchantPrepareID,
            cb.Amount, cb.Action, cb.SignTime)
    } else {
        respondJSON(w, map[string]interface{}{"error": -3, "error_note": "Action not found"})
        return
    }

    hash := md5.Sum([]byte(signSource))
    expectedSign := hex.EncodeToString(hash[:])

    // Constant-time comparison
    if subtle.ConstantTimeCompare([]byte(cb.SignString), []byte(expectedSign)) != 1 {
        respondJSON(w, map[string]interface{}{"error": -1, "error_note": "SIGN CHECK FAILED!"})
        return
    }

    switch cb.Action {
    case "0":
        handlePrepare(w, cb)
    case "1":
        handleComplete(w, cb)
    }
}

func respondJSON(w http.ResponseWriter, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(data)
}
```

## Security Checklist

- [ ] Verify sign_string on every request with constant-time comparison
- [ ] Validate service_id matches your service
- [ ] Check `error` field in both Prepare and Complete
- [ ] Protect against duplicate click_trans_id processing
- [ ] Verify merchant_prepare_id in Complete matches the Prepare record
- [ ] Use atomic transactions for fulfillment + status update
- [ ] Log click_paydoc_id for audit trail and support queries
- [ ] Use HTTPS for callback URLs
- [ ] Return JSON with ALL required fields even on error
