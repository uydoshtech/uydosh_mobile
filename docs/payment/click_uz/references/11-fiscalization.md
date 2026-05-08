# Fiscalization (Фискализация данных)

> Source: https://docs.click.uz/fiscalization/

## Overview

Fiscalization is **mandatory** in Uzbekistan for online payments. If you use more than 1 IKPU code, you **must** integrate the fiscalization endpoint. Click provides three methods:

1. **submit_items** — Send item details, Click generates the fiscal receipt
2. **submit_qrcode** — Send your own pre-generated fiscal receipt QR code URL
3. **GET ofd_data** — Retrieve fiscal receipt URL for a payment

All use Merchant API authentication (SHA1 digest in `Auth` header).

**IMPORTANT**: `received_ecash`, `received_cash`, `received_card` amounts and item prices are in **tiyin** (1 so'm = 100 tiyin), NOT in so'm! This is different from payment amounts which are in so'm.

---

## 1. Submit Items (Фискализация товаров и услуг)

Click generates the fiscal receipt based on your item data.

### Request

```http
POST https://api.click.uz/v2/merchant/payment/ofd_data/submit_items HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "payment_id": 1234567890,
  "items": [
    {
      "Name": "Premium obuna 1 oy dona",
      "SPIC": "10305001001000001",
      "PackageCode": "123456",
      "GoodPrice": 5000000,
      "Price": 5000000,
      "Amount": 1,
      "VAT": 750000,
      "VATPercent": 15,
      "CommissionInfo": {
        "TIN": "123456789"
      }
    }
  ],
  "received_ecash": 5000000,
  "received_cash": 0,
  "received_card": 0
}
```

### Request Parameters

| # | Parameter | Type | Required | Description |
|---|-----------|------|----------|-------------|
| 1 | service_id | integer | Yes | Service ID |
| 2 | payment_id | long | Yes | Click payment ID (click_paydoc_id from SHOP API) |
| 3 | items | Item[] | Yes | Array of items (minimum 1 item) |
| 4 | received_ecash | integer | Yes | Amount received as e-cash in **tiyin** |
| 5 | received_cash | integer | Yes | Amount received as cash in **tiyin** |
| 6 | received_card | integer | Yes | Amount received by card in **tiyin** |

### Item Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Name | string(63) | **Yes*** | Product/service name with unit of measurement at the end |
| Barcode | string(13) | No | Barcode |
| Labels | [300]string(21) | No | Array of marking codes (max 300 elements) |
| SPIC | string(17) | **Yes*** | IKPU code (product identification code) |
| Units | uint64 | No | Unit of measurement code |
| PackageCode | string(20) | **Yes*** | Package code |
| GoodPrice | uint64 | No | Price of one product/service unit in **tiyin** |
| Price | uint64 | **Yes*** | Total position amount (qty × price, no discounts) in **tiyin** |
| Amount | uint64 | **Yes*** | Quantity |
| VAT | uint64 | **Yes*** | VAT amount in **tiyin** |
| VATPercent | int (byte) | **Yes*** | VAT percentage (e.g., 12 or 15) |
| Discount | uint64 | No | Discount in **tiyin** |
| Other | uint64 | No | Other discount (insurance, etc.) in **tiyin** |
| CommissionInfo | CommissionInfo | **Yes*** | Commission receipt information |

Fields marked with * are mandatory.

### CommissionInfo Object

Must contain either TIN or PINFL (at least one):

| Field | Type | Description |
|-------|------|-------------|
| TIN | string(9) | INN — tax identification number (9 digits) |
| PINFL | string(14) | PINFL — personal identification number (14 digits) |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success"
}
```

---

## 2. Submit QR Code (Отправка фискализированного чека)

If you generate fiscal receipts through your own OFD system (e.g., via soliq.uz), send the receipt QR code URL to Click.

### Request

```http
POST https://api.click.uz/v2/merchant/payment/ofd_data/submit_qrcode HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543

{
  "service_id": 85335,
  "payment_id": 1234567890,
  "qrcode": "https://ofd.soliq.uz/epi?t=EZ000000000030&r=123456789&c=20221028171340&s=854971301623"
}
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | payment_id | long | Click payment ID |
| 3 | qrcode | string | OFD receipt URL (from soliq.uz or your OFD provider) |

### Response

```json
{
  "error_code": 0,
  "error_note": "Success"
}
```

---

## 3. Get Fiscal Data (Получение фискальных данных)

Retrieve the fiscal receipt URL for a payment.

### Request

```http
GET https://api.click.uz/v2/merchant/payment/ofd_data/:service_id/:payment_id HTTP/1.1
Accept: application/json
Content-Type: application/json
Auth: 123:356a192b7913b04c54574d18c28d46e6395428ab:1519051543
```

### Request Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | service_id | integer | Service ID |
| 2 | payment_id | long | Click payment ID |

### Response

```json
{
  "paymentId": 1946296773,
  "qrCodeURL": "https://ofd.soliq.uz/epi?t=EZ000000000030&r=123456789&c=20221028171340&s=854971301623"
}
```

### Response Parameters

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | paymentId | long | Payment ID |
| 2 | qrCodeURL | string | Fiscal receipt URL |

---

## IKPU Codes

IKPU (Identifikatsion Kod Produkt Usluga) codes identify products and services for tax purposes.

- Look up codes at: **https://tasnif.soliq.uz/**
- SPIC field = the IKPU code itself (17-digit string)
- PackageCode = package code from IKPU details
- Units = unit of measurement code from classifier

## When to Call Fiscalization

1. Receive Complete callback with error=0 (payment successful)
2. Fulfill the order
3. Call `submit_items` with item details OR `submit_qrcode` with your own receipt
4. Log the result

If fiscalization fails, log the error but don't block order fulfillment — retry fiscalization separately.
