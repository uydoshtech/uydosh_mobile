# Payment Button — With Redirect (Кнопка оплаты — С переходом)

> Source: https://docs.click.uz/click-button/

## Overview

This page describes how to redirect users to the Click payment page at my.click.uz. The user clicks a button/link on your site, gets redirected to Click's payment form, pays, and is redirected back.

## Option 1 — Redirect by Link (URL)

Create a button/link to the following address:

```
https://my.click.uz/services/pay?service_id={service_id}&merchant_id={merchant_id}&amount={amount}&transaction_param={transaction_param}&return_url={return_url}&card_type={card_type}
```

### URL Parameters

| # | Parameter | Required | Description |
|---|-----------|----------|-------------|
| 1 | merchant_id | mandatory | Merchant ID |
| 2 | merchant_user_id | optional | User ID in merchant system |
| 3 | service_id | mandatory | Merchant service ID |
| 4 | transaction_param | mandatory | Order ID / personal account / login. Corresponds to `merchant_trans_id` from SHOP-API |
| 5 | amount | mandatory | Transaction amount (format: **N.NN**, e.g., `50000.00`) |
| 6 | return_url | optional | URL where user will be redirected after payment |
| 7 | card_type | optional | Payment system type: `uzcard` or `humo` |

## Option 2 — Redirect by HTML Form

```html
<form action="https://my.click.uz/services/pay" method="get" target="_blank">
    <button type="submit" class="pay_with_click"><i></i>Pay with CLICK</button>
    <input type="hidden" name="merchant_id" value="{MERCHANT_ID}" />
    <input type="hidden" name="merchant_user_id" value="{MERCHANT_USER_ID}" />
    <input type="hidden" name="service_id" value="{SERVICE_ID}" />
    <input type="hidden" name="transaction_param" value="{ORDER_ID}" />
    <input type="hidden" name="amount" value="{AMOUNT}" />
    <input type="hidden" name="return_url" value="{RETURN_URL}" />
    <input type="hidden" name="card_type" value="{CARD_TYPE}" />
</form>
```

Same parameters as Option 1, passed via hidden input fields.

### PHP Code Example

```php
<?php
$merchantID = 20;       // Replace with your ID
$merchantUserID = 4;
$serviceID = 31;
$transID = "user23151";
$transAmount = number_format(1000, 2, '.', '');
$returnURL = "https://your-site.uz/payment/result";
$cardType = "uzcard";

$HTML = <<<CODE
<form action="https://my.click.uz/services/pay" id="click_form" method="get" target="_blank">
    <input type="hidden" name="amount" value="$transAmount" />
    <input type="hidden" name="merchant_id" value="$merchantID"/>
    <input type="hidden" name="merchant_user_id" value="$merchantUserID"/>
    <input type="hidden" name="service_id" value="$serviceID"/>
    <input type="hidden" name="transaction_param" value="$transID"/>
    <input type="hidden" name="return_url" value="$returnURL"/>
    <input type="hidden" name="card_type" value="$cardType"/>
    <button type="submit" class="click_logo"><i></i>Pay with CLICK</button>
</form>
CODE;
?>
```

### Final HTML Code Example

```html
<form id="click_form" action="https://my.click.uz/services/pay" method="get" target="_blank">
  <input type="hidden" name="amount" value="1000" />
  <input type="hidden" name="merchant_id" value="46"/>
  <input type="hidden" name="merchant_user_id" value="4"/>
  <input type="hidden" name="service_id" value="36"/>
  <input type="hidden" name="transaction_param" value="user23151"/>
  <input type="hidden" name="return_url" value="merchant website url"/>
  <input type="hidden" name="card_type" value="uzcard/humo"/>
  <button type="submit" class="click_logo"><i></i>Pay with CLICK</button>
</form>
```

### CSS Code for Button

```css
.click_logo {
  padding: 4px 10px;
  cursor: pointer;
  color: #fff;
  line-height: 190%;
  font-size: 13px;
  font-family: Arial;
  font-weight: bold;
  text-align: center;
  border: 1px solid #037bc8;
  text-shadow: 0px -1px 0px #037bc8;
  border-radius: 4px;
  background: linear-gradient(#27a8e0 0%, #1c8ed7 100%);
  box-shadow: inset 0px 1px 0px #45c4fc;
}

.click_logo i {
  background: url(https://m.click.uz/static/img/logo.png) no-repeat top left;
  width: 30px;
  height: 25px;
  display: block;
  float: left;
}
```
