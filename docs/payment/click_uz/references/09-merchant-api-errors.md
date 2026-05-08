# Merchant API — Error Codes (Ошибки)

> Source: https://docs.click.uz/merchant-api-error/

## HTTP Status Codes

Authentication and other API-related errors are returned using HTTP status codes.

| # | HTTP Code | Description (EN) | Description (RU) |
|---|-----------|------------------|-------------------|
| 1 | 200 | OK | OK |
| 2 | 201 | OK (Created) | OK |
| 3 | 400 | Bad request (malformed data or URI) | Плохой, неверный запрос |
| 4 | 401 | Not Authorized (auth error) | Не авторизован |
| 5 | 403 | Forbidden (method not allowed) | Запрещено |
| 6 | 404 | Not Found (method not found) | Не найдено |
| 7 | 406 | Not Acceptable (invalid data type) | Неприемлемо |
| 8 | 410 | Gone (deprecated method) | Неприемлемо (устаревший метод) |
| 9 | 500 | Internal Server Error (critical error in API) | Внутренняя ошибка сервера |
| 10 | 502 | Service is down or being upgraded | Сервис недоступен или обновляется |

## Response Body Error Codes

In addition to HTTP status codes, API responses contain `error_code` and `error_note` fields:

```json
{
  "error_code": 0,
  "error_note": "Success"
}
```

- `error_code = 0` — success
- `error_code != 0` — error (check error_note for details)

## Troubleshooting Common Errors

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| 401 | Wrong Auth header format or invalid digest | Verify: `SHA1(timestamp + secret_key)`, timestamp must be current |
| 403 | Calling a method you don't have access to | Check your merchant_user_id permissions |
| 400 | Missing required parameters or wrong format | Verify JSON body and URL path parameters |
| 404 | Wrong URL path or method name | Check endpoint URL matches documentation |
| 406 | Wrong Content-Type header | Must be `application/json` or `application/xml` |
