# Telegram Bot Payments (Оплата через Telegram)

> Source: https://docs.click.uz/telegram-payments/

## 1. Create a New Bot

Use the official **@BotFather** bot. Search for `@BotFather` in Telegram, start it, and you'll see a list of commands.

## 2. Bot Name

Send `/newbot` command to @BotFather. It will ask you to give a name to your bot. Only Latin letters and digits allowed. Spaces are allowed between letters and digits.

## 3. Bot Username

The bot username is the address of your bot — users will find it by this name. Create a short, memorable name. It **must end with "bot"**. No spaces allowed. If the name is taken, you'll be asked to choose another. After this, @BotFather generates a **token** — your Bot API ID.

## 4. Connect Bot to CLICK Terminal

### Get Provider Token

1. Send `/mybots` in @BotFather chat
2. Select the bot you want to use for payments
3. Go to **Settings > Payments**
4. In the list of payment systems, select **"CLICK Uzbekistan"**
5. @BotFather offers **test** or **live** connection

### Test Mode

1. Select **"Connect CLICK Terminal Test"**
2. You'll be redirected to **@CLICKtest** bot
3. Click **Start**, then click **"Авторизоваться" (Authorize)**
4. You'll be redirected back to @BotFather with test provider_token

### Live Mode

1. Select **"Connect CLICK Terminal Live"**
2. You'll be redirected to **@CLICKTerminal** bot
3. Click **Start**, then **"Авторизоваться" (Authorize)**
4. Browser opens with authorization form — log in with your merchant cabinet credentials
5. Select your service
6. You'll get a live token containing `:LIVE:` in the middle (e.g., `123:LIVE:XXXX`)

> **WARNING**: Do not share your live token with third parties!

## 5. Contract Requirements

To accept payments through CLICK, the supplier must:
- Be a **legal entity** or **individual entrepreneur**
- Sign a contract with one of the connected banks

**Connected banks**: Алокабанк, Агро банк, Давр банк, Узпромстройбанк, Кишлок Курилиш банк, Узбекско-Турецкий банк, Универсал банк, Савдогар банк, Траст банк, Туркистон банк, Халк банк, Микрокредит банк, Ориент Финанс банк, Asia Alliance Bank, Ипак Йули банк

**No subscription or connection fee** — only commission (% of turnover paid to bank).

### Required Documents (copies)

1. Certificate of registration
2. License (if activity requires licensing)
3. Order of appointment of director
4. Director's passport
5. Protocol of founders' meeting on director appointment
6. Charter/Articles (all pages)
7. Domain agreement
8. Connection letter (only for "Asia Alliance Bank")

Phone for inquiries: **+998 (71) 231-08-83**

## 6. Testing Payment Flow

### Step 1: Create Invoice

Use the `sendInvoice` Bot API method. In `provider_token` parameter, specify the token from @BotFather. One bot can use multiple tokens for different users or products.

Invoices with payment button can only be sent to users who messaged the bot. Cannot be sent to groups or channels.

### Step 2: Verify and Confirm Order

After user enters information and clicks **"Pay"**, Bot API sends an **Update** with `pre_checkout_query` field containing all order information.

> **CRITICAL**: Your bot must respond with `answerPrecheckoutQuery` within **10 seconds** after receiving `pre_checkout_query`, or the transaction will be **cancelled**.

If the bot cannot process the order for any reason, it returns an error. Recommended: write user-friendly error text like "Sorry, this item is out of stock, would you be interested in our other products?"

### Step 3: Payment

After bot confirms the order, Telegram asks the payment system to complete the transaction. If payment succeeds, Bot API sends a message of type `successful_payment` from the user.

User sees a receipt/check and can open it anytime to view payment details.

## 7. Switch to LIVE Mode

1. Go to @BotFather
2. Send `/mybots`, select your bot
3. **Settings > Payments > CLICK Uzbekistan**
4. Select **"Connect CLICK Terminal LIVE"**
5. Redirected to **@CLICKTerminal**
6. Click **Start** → **"Авторизоваться"**
7. Login with merchant cabinet credentials, select service
8. Receive live token (contains `:LIVE:`)

### Before Going LIVE, Ensure:

- **Two-factor authentication** is enabled on the Telegram account managing the bot
- You are fully responsible for handling disputes and refunds
- Bot responds to `/terms` command with Terms and Conditions
- Bot responds to `/support` command with customer support contact
- Users must confirm they've read and agreed to terms before purchasing
- Your server hardware and software is stable — use backups

## Code Examples

### Node.js (node-telegram-bot-api)

```javascript
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(BOT_TOKEN, { polling: true });
const PROVIDER_TOKEN = process.env.CLICK_PROVIDER_TOKEN;

// Create invoice
bot.onText(/\/pay/, async (msg) => {
  await bot.sendInvoice(
    msg.chat.id,
    'Premium Subscription',
    '1 month premium access',
    `premium_${msg.from.id}_${Date.now()}`,
    PROVIDER_TOKEN,
    'UZS',
    [{ label: 'Premium (1 month)', amount: 5000000 }] // Amount in TIYIN for Telegram
  );
});

// Terms (required for live mode)
bot.onText(/\/terms/, (msg) => {
  bot.sendMessage(msg.chat.id, 'Terms of Service: https://your-site.uz/terms');
});

// Support (required for live mode)
bot.onText(/\/support/, (msg) => {
  bot.sendMessage(msg.chat.id, 'Support: support@your-site.uz');
});

// Pre-checkout verification — MUST respond within 10 seconds!
bot.on('pre_checkout_query', async (query) => {
  try {
    const isValid = await verifyOrder(query.invoice_payload);
    await bot.answerPreCheckoutQuery(query.id, isValid);
  } catch (err) {
    await bot.answerPreCheckoutQuery(query.id, false, {
      error_message: 'Error processing order, please try again'
    });
  }
});

// Successful payment
bot.on('message', async (msg) => {
  if (msg.successful_payment) {
    const payment = msg.successful_payment;
    await fulfillOrder(payment.invoice_payload);
    await bot.sendMessage(msg.chat.id, 'Payment successful!');
  }
});
```

> **NOTE**: Telegram Bot Payments use amounts in the **smallest currency unit**. For UZS, this is **tiyin** (1 UZS = 100 tiyin). So 50,000 UZS = 5,000,000 tiyin. This is different from SHOP API/Merchant API which use so'm!
