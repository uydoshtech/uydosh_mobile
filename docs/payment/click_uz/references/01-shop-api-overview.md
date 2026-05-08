# SHOP API — Overview (Общее)

> Source: https://docs.click.uz/click-api/

## General Provisions

This document describes the procedure of interaction between the billing system of the suppliers of goods and services (including online stores) and CLICK system through the interaction interface of CLICK-API (hereinafter API) to carry out online sales of their goods and services through the web-site, e-mail / SMS or other tools available to the supplier.

## Terms and Definitions

**CLICK System** — a system that allows to make payments via mobile phone (via USSD/SMS-portal) or the internet (via WEB/mobile WEB) for the services of cellular service providers, internet service providers; transfer cash assets to other individuals, trade and service companies; perform online shopping in online stores, etc. from the accounts opened in the bank.

**Supplier (Поставщик)** — a legal person which sells goods or services to customers.

**User (Пользователь)** — an individual connected to CLICK system.

**Services of the Supplier (Сервисы поставщика)** — subjects which are sold by the supplier. Goods and services can be services.

**Supplier's Billing System (Биллинг система Поставщика)** — the system of the supplier to account for the users of the goods or service of the provider. The hardware and software that allows to conduct accounting and payment transactions electronically between the supplier and the customer while preserving the history of operations, as well as providing the API-interface for communication with external payment systems.

## Payment Flow

```
┌──────────┐    ┌─────────────┐    ┌───────────────────────┐
│   User   │───>│ Click System│───>│ Supplier Billing      │
│          │    │             │    │ System (Your Server)   │
│ Pays via │    │ 1. Prepare  │───>│ Verify order/amount   │
│ Click    │    │    (action=0)│<──│ Return merchant_       │
│ app/web  │    │             │    │ prepare_id             │
│          │    │ 2. Deduct $ │    │                       │
│          │    │             │    │                       │
│          │    │ 3. Complete │───>│ Fulfill order         │
│          │    │    (action=1)│<──│ Return merchant_       │
│          │    │             │    │ confirm_id             │
└──────────┘    └─────────────┘    └───────────────────────┘
```

### Flow Description

1. **Prepare Phase**: Click sends a Prepare request (action=0) to the supplier's billing system to verify the order/account and reserve the product.

2. **Payment Phase**: If Prepare is successful, Click attempts to deduct funds from the user's account.

3. **Complete Phase**: 
   - If funds deducted successfully (error=0): Click sends Complete request — supplier must fulfill the order
   - If funds deduction failed (error<0): Click sends Complete with cancellation — supplier must unreserve

### Payment Interfaces

Payment interfaces are divided into two categories:

**Click Payment Interfaces** (where users can pay):
- CLICK SuperApp mobile app
- Web payment service my.click.uz
- USSD service
- Telegram bot

**Merchant Payment Interfaces** (where merchants can initiate):
- Merchant website
- Merchant mobile app

When the merchant's billing system meets requirements (implementation of **Prepare** and **Complete** requests described in SHOP API), merchant services can be available for payment via ANY of the Click payment interfaces.
