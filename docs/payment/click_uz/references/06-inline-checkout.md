# Inline Checkout — Pay by Card Without Redirect (Оплата по карте без перехода)

> Source: https://docs.click.uz/click-pay-by-card/

## Overview

This method allows users to pay directly on your site without being redirected to my.click.uz. The `checkout.js` script creates a payment overlay/modal on your page.

## Variant 1 — Auto-generated Payment Button (Script Tag in Form)

Add the `<script>` tag inside your payment form to auto-generate a payment button:

```html
<form method="post" action="/your-after-payment-url">
    <script src="https://my.click.uz/pay/checkout.js"
        class="uzcard_payment_button"
        data-service-id="MERCHANT_SERVICE_ID"
        data-merchant-id="MERCHANT_ID"
        data-transaction-param="MERCHANT_TRANS_ID"
        data-merchant-user-id="MERCHANT_USER_ID"
        data-amount="MERCHANT_TRANS_AMOUNT"
        data-card-type="MERCHANT_CARD_TYPE"
        data-label="Оплатить" <!-- Button text -->
    ></script>
</form>
```

### Parameters (data attributes)

| # | Parameter | Required | Description |
|---|-----------|----------|-------------|
| 1 | MERCHANT_ID (data-merchant-id) | mandatory | Merchant ID |
| 2 | MERCHANT_USER_ID (data-merchant-user-id) | optional | User ID in merchant system |
| 3 | MERCHANT_SERVICE_ID (data-service-id) | mandatory | Service ID |
| 4 | MERCHANT_TRANS_ID (data-transaction-param) | mandatory | Order ID / personal account. Corresponds to `merchant_trans_id` from SHOP-API |
| 5 | MERCHANT_TRANS_AMOUNT (data-amount) | mandatory | Transaction amount (format: N.NN) |
| 6 | MERCHANT_CARD_TYPE (data-card-type) | optional | Payment system type (uzcard, humo) |

### After Payment

After the payment is completed in the payment window, the form will be submitted to the server with an additional parameter **`status`**.

## Variant 2 — JavaScript API (`createPaymentRequest`)

Include the checkout.js script and call `createPaymentRequest()` method which accepts two parameters:
1. Payment parameters object
2. Callback function — called after payment window closes, receives object with `status` field

```html
<script src="https://my.click.uz/pay/checkout.js"></script>
<script>
window.onload = function() {
    var linkEl = document.querySelector(".input-btn");
    linkEl.addEventListener("click", function() {
        createPaymentRequest({
            service_id: MERCHANT_SERVICE_ID,
            merchant_id: MERCHANT_ID,
            amount: MERCHANT_TRANS_AMOUNT,
            transaction_param: "MERCHANT_TRANS_ID",
            merchant_user_id: "MERCHANT_USER_ID",
            card_type: "MERCHANT_CARD_TYPE",
        }, function(data) {
            console.log("closed", data.status);
        });
    });
};
</script>
```

### Parameters (createPaymentRequest object)

| # | Parameter | Required | Description |
|---|-----------|----------|-------------|
| 1 | merchant_id | mandatory | Merchant ID |
| 2 | merchant_user_id | optional | User ID in merchant system |
| 3 | service_id | mandatory | Service ID |
| 4 | transaction_param | mandatory | Order ID / personal account. Corresponds to `merchant_trans_id` from SHOP-API |
| 5 | amount | mandatory | Transaction amount (format: N.NN) |
| 6 | card_type | optional | Payment system type (uzcard, humo) |

### Status Values (callback `data.status`)

| status | Description |
|--------|-------------|
| < 0 | Error |
| 0 | Payment created |
| 1 | Payment is being processed |
| 2 | Payment was successful |

## Usage Notes

- The checkout.js script URL is: `https://my.click.uz/pay/checkout.js`
- Both variants still require SHOP API (Prepare/Complete) to be implemented on your server
- The payment form appears as an overlay on your page — no navigation away from your site
- After payment, check the status and verify on your backend via SHOP API callbacks or Merchant API status check
