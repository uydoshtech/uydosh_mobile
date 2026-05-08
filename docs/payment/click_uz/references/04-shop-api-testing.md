# SHOP API — Testing (Тестирование)

> Source: https://docs.click.uz/click-api-testing/

## Testing and Debugging API-Interface

For testing and debugging the API-interface during development, use this software:
**Download**: https://docs.click.uz/wp-content/uploads/2018/05/NEW-CLICK_API.zip

This software (PO) emulates the actions of the CLICK system. The supplier configures the software and tests step-by-step using pre-loaded scenarios.

> **NOTE**: This testing software is from 2018 and may not work on modern Windows systems. Alternative approach: perform a real small-amount test payment (minimum 500 so'm) against your production-ready endpoint.

## Testing Software Field Descriptions

| # | Parameter | Type | Description |
|---|-----------|------|-------------|
| 1 | Prepare URL | varchar | Link to API-interface handler for Prepare request |
| 2 | Complete URL | varchar | Link to API-interface handler for Complete request |
| 3 | service_id | int | Service ID obtained during registration in CLICK system |
| 4 | merchant_user_id | int | User ID obtained during registration in CLICK system |
| 5 | secret_key | varchar | Secret key for signature formation, obtained during registration |
| 6 | merchant_trans_id | varchar | Payment ID of online store systems (your test order ID) |
| 7 | prepare/confirm_id | read only | Filled in automatically when running the script |

## Testing Procedure

1. Fill in all data fields listed above
2. Select a scenario from the dropdown menu
3. Click **"Начать тест" (Start Test)**
4. Description of each scenario is shown in the "Описание сценариев" (Scripts Description) table
5. Certain scenarios may automatically transition to the next scenario after successful completion
6. Each test runs with detailed description of passed parameters and received answer in the **"Лог тестирования" (Test Log)** window
7. In this window you can see request/response and analyze identified errors
8. If scenario passes: "Выполнено" (Completed) status in the scripts table
9. **ALL scenarios must pass successfully**
10. After passing all tests, click **"Сформировать отчет" (Generate Report)**

## Report Generation

Clicking "Generate Report" initiates:
1. Data reconciliation procedure
2. Sends all necessary parameters to the CLICK registration server
3. Requires internet access
4. Success message: **"Статус регистрации отчета: Регистрация успешно завершена!"** ("Registration Status report: Registration completed successfully!")

This means your data was successfully added to CLICK.

## Verification

Successful data addition can be verified through: **http://merchant.click.uz**

## Important Notes

- The URL specified in the program must be accessible to the testing software (can be on a local computer — localhost is OK for testing software, but NOT for real Click system)
- For production: URLs must be publicly accessible HTTPS endpoints
- If you can't use the testing software, do a real small-amount payment test (minimum 500 so'm)
- Request service activation from Click support BEFORE attempting real payments
