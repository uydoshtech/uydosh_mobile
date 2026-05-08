# Mobile SDK Integration (Мобильная интеграция)

> Source: https://docs.click.uz/mobile-integration/

## Integration with Android and iOS Mobile Apps

The Click mobile application on both platforms intercepts links (deeplinks) for payment. See https://docs.click.uz/click-button/ for how the payment link is created.

If the Click app is **not installed** on the user's phone, the system browser opens and the user can pay on the web page.

## Android Code Example (Kotlin)

```kotlin
val url =
    "https://my.click.uz/services/pay/?service_id=${it.merchantServiceId}&merchant_id=${it.merchantId}&amount=${it.merchantTransAmount}&transaction_param=${it.merchantTransId}"
val i = Intent(Intent.ACTION_VIEW)
i.data = Uri.parse(url)
startActivity(i)
```

## How Click Evolution Works

After successful payment, the Click application simply **closes itself**. In your code, in the `onStart` or `onRestart` method, you can update the data from your server using the `transaction_param` that you previously used.

### return_url Handling

If you added `return_url` as a parameter to the payment link, then after payment (even after an error), this link will be called in the Click application as `Intent.ACTION_VIEW` and the Click app will close itself.

You can listen for (deeplink) `return_url` in your application by binding it to your Activity. You can also use unique URL schemes.

See: https://developer.android.com/training/app-links/deep-linking

### Example: Custom URL Scheme

```kotlin
// In your payment initiation:
val returnUrl = "myapp://payment/result?order_id=${orderId}"
val url = "https://my.click.uz/services/pay/?service_id=$serviceId&merchant_id=$merchantId&amount=$amount&transaction_param=$orderId&return_url=${URLEncoder.encode(returnUrl, "UTF-8")}"

val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
startActivity(intent)
```

```xml
<!-- In AndroidManifest.xml — register your Activity for the deep link -->
<activity android:name=".PaymentResultActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" android:host="payment" android:pathPrefix="/result" />
    </intent-filter>
</activity>
```

## iOS Code Example (Swift)

```swift
guard let url = URL(string: "https://my.click.uz/services/pay/?service_id=\(merchantServiceId)&merchant_id=\(merchantId)&amount=\(merchantTransAmount)&transaction_param=\(merchantTransId)") else { return }
UIApplication.shared.open(url)
```

### iOS return_url Handling

Use a custom URL scheme or Universal Links to receive the callback:

```swift
// In your payment initiation:
let returnUrl = "myapp://payment/result?order_id=\(orderId)"
let encodedReturn = returnUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
let paymentUrl = "https://my.click.uz/services/pay/?service_id=\(serviceId)&merchant_id=\(merchantId)&amount=\(amount)&transaction_param=\(orderId)&return_url=\(encodedReturn)"

guard let url = URL(string: paymentUrl) else { return }
UIApplication.shared.open(url)
```

## Android Mobile SDK

For deeper integration with Android, use the **Click Mobile SDK** library. This library can be used for both merchants with billing and merchants without billing. For merchants with billing, you need to implement SHOP-API on the application server.

**Library and detailed documentation**: https://github.com/click-llc/android-msdk

### SDK vs Deep Link

| Aspect | Deep Link | Mobile SDK |
|--------|-----------|------------|
| Platform | Android + iOS | Android only |
| Integration | Simple URL | Gradle dependency |
| Customization | None (Click's UI) | More control |
| Billing required | Optional | Required for billing merchants |
| Fallback | Browser if app not installed | SDK handles UI |

## Payment Link Parameters (for both platforms)

| Parameter | Required | Description |
|-----------|----------|-------------|
| service_id | Yes | Your service ID |
| merchant_id | Yes | Your merchant ID |
| amount | Yes | Amount in so'm (N.NN format) |
| transaction_param | Yes | Order ID (maps to merchant_trans_id) |
| return_url | No | Deep link URL for callback after payment |
| card_type | No | Filter: `uzcard` or `humo` |

## Important Notes

1. **Always verify payment on your server** — do not trust client-side callbacks alone. Use SHOP API Prepare/Complete or Merchant API payment status check.
2. **return_url fires on both success and error** — check payment status on your server after receiving the callback.
3. **URL-encode the return_url** parameter when embedding in the payment URL.
4. **Click app closing behavior** — after payment, Click closes itself; your app resumes from `onStart`/`onRestart` (Android) or `applicationDidBecomeActive` (iOS).
