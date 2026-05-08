# Merchant API — Overview (Общее)

> Source: https://docs.click.uz/merchant/

## General Provisions

The CLICK-API-MERCHANT-INVOICE interface is used to place invoice requests to a user, by a supplier through the internet, check the status of issued invoices, and cancel payments.

## Terms and Definitions

**CLICK Payment System** — a system that allows payments via mobile phone (USSD/SMS) or the internet (WEB/Mobile) for the services of cellular operators, internet providers; make payments in offline or online shops.

**Supplier (Поставщик)** — a legal entity that sells goods or services to users.

**User (Пользователь)** — an individual connected to the CLICK payment system.

**Supplier Services (Сервисы поставщика)** — services and goods offered by the supplier.

## Payment Flow (Merchant API)

Unlike SHOP API where Click calls your server, with Merchant API YOUR server calls Click's API:

```
┌──────────────┐    ┌─────────────┐    ┌──────────┐
│ Your Server  │───>│ Click API   │───>│ User     │
│              │    │             │    │          │
│ 1. Create    │───>│ Create      │───>│ Receives │
│    invoice   │    │ invoice     │    │ push/SMS │
│              │    │             │    │          │
│              │    │             │    │ Confirms │
│              │    │             │<───│ payment  │
│              │    │             │    │ in app   │
│ 2. Check     │───>│ Payment     │    │          │
│    status    │<───│ status      │    │          │
│              │    │             │    │          │
│ 3. (Optional)│───>│ Reversal    │    │          │
│    Cancel    │    │             │    │          │
└──────────────┘    └─────────────┘    └──────────┘
```

## Merchant API Capabilities

1. **Create Invoice** — send payment notification to user's phone
2. **Check Invoice Status** — verify if invoice was paid
3. **Check Payment Status** — check status by payment_id or merchant_trans_id
4. **Payment Reversal** — cancel/refund a payment
5. **Card Token Management** — create, verify, pay with, and delete card tokens
6. **CLICK Pass** — QR-code POS payments
7. **Fiscalization** — submit fiscal data for tax compliance

## Contract and Legal Requirements

To accept payments through CLICK, the supplier must:

1. Be a **legal entity** or **individual entrepreneur**
2. Sign a contract with one of the connected banks:
   - Алокабанк, Агро банк, Давр банк, Узпромстройбанк
   - Кишлок Курилиш банк, Узбекско-Турецкий банк, Универсал банк
   - Савдогар банк, Траст банк, Туркистон банк, Халк банк
   - Микрокредит банк, Ориент Финанс банк, Asia Alliance Bank
   - Ипак Йули банк
   - *(list is constantly expanding — check with your manager)*

**No subscription or connection fee.** Supplier pays only commission (% of turnover).

### Required Documents (copies)

1. Certificate of registration
2. License (if activity requires mandatory licensing)
3. Order of appointment of director
4. Director's passport
5. Protocol of founders' meeting on appointment of director
6. Charter/Articles (all pages)
7. Domain agreement
8. Connection letter (only for ACB "Asia Alliance Bank")

*Document list may vary slightly by bank.*

**Support phone**: +998 (71) 231-08-83
