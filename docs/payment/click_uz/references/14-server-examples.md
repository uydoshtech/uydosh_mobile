# Server Implementation Examples (Пример реализации)

> Source: https://docs.click.uz/server-example/

## Official Click Repositories

### PHP

Implementation example and detailed documentation:
**https://github.com/click-llc/click-integration-php**

### Python Django

Implementation example and detailed documentation:
**https://github.com/click-llc/click-integration-django**

---

## Community Repositories

### Node.js (Express + MongoDB) — by samarbadriddin0v

**https://github.com/samarbadriddin0v/click-uz-integration-nodejs** (82+ stars)

Stack: Node.js, Express.js, MongoDB

```bash
npm install
# Setup .env:
# PORT=4040
# CLIENT_URL=http://localhost:3000
# MONOGO_URI=mongodb://localhost:27017/click
# CLICK_SECRET_KEY=
# CLICK_SERVICE_ID=
# CLICK_MERCHANT_ID=
# CLICK_MERCHANT_USER_ID=
# CLICK_CHECKOUT_LINK=https://my.click.uz
npm start
```

### TypeScript (Fastify + Prisma + Zod) — by idafoh

**https://github.com/idafoh/click-uz-shop-api-example** (3+ stars)

100% typesafe SHOP-API implementation.

Stack: Node.js, Fastify, Prisma, Zod, TypeScript

```bash
npm install
npm run migrate:dev
npm run build
npm start
```

### Node.js (Express) — by umaralimuminjonov

**https://github.com/umaralimuminjonov/click-integration-example** (12+ stars)

Stack: Express, MongoDB

### Node.js — by Magicsoftuz

**https://github.com/Magicsoftuz/click-uz-integration-nodejs**

Forked and maintained version with Express.

---

## Choosing a Stack

| Stack | Official | Community | Notes |
|-------|----------|-----------|-------|
| PHP | ✅ click-llc | — | Official, well-documented |
| Python/Django | ✅ click-llc | — | Official, well-documented |
| Node.js/Express | — | ✅ Multiple repos | Most popular community option |
| TypeScript/Fastify | — | ✅ idafoh | Type-safe, Prisma ORM |
| Go | — | — | See code examples in `02-shop-api-requests.md` and `08-merchant-api-requests.md` |
| Any language | — | — | SHOP API is simple HTTP POST — implement in any language following the spec |
