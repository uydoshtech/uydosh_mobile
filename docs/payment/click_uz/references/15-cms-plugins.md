# CMS Plugins (Плагины для CMS)

> Source: https://docs.click.uz/plugins-for-cms/

## Available Plugins

Click provides official plugins for popular CMS platforms. These plugins handle the SHOP API integration (Prepare/Complete callbacks) automatically.

| # | CMS | Supported Version | Download Link |
|---|-----|-------------------|---------------|
| 1 | **WordPress** (WooCommerce) | 3.5+ | https://github.com/click-llc/woocommerce-clickuz-gateway |
| 2 | **Drupal** (Ubercart) | 7.x-3.11+ | https://docs.click.uz/wp-content/uploads/2018/10/uc_click.zip |
| 3 | **OpenCart** | 3.x | https://github.com/click-llc/opencart |
| 4 | **1C-Bitrix** | 20.x | https://github.com/click-llc/1c-bitrix |
| 5 | **Joomla!** (VirtueMart) | 3.x | https://github.com/click-llc/joomla-virtuemart |
| 6 | **CS-Cart** | 4.5.x | https://github.com/click-llc/cs-cart |

## Installation Notes

### WordPress / WooCommerce

1. Download from GitHub: https://github.com/click-llc/woocommerce-clickuz-gateway
2. Upload to `wp-content/plugins/` directory
3. Activate in WordPress admin → Plugins
4. Go to WooCommerce → Settings → Payments → Click
5. Enter your `merchant_id`, `service_id`, `SECRET_KEY`
6. Set callback URLs in Click merchant cabinet to point to your WordPress site

### OpenCart

1. Download from GitHub: https://github.com/click-llc/opencart
2. Upload extension files to your OpenCart installation
3. Go to Extensions → Payments → Click
4. Configure with your Click credentials

### General Plugin Setup

For all plugins:
1. Install the plugin for your CMS
2. Configure with your Click credentials (merchant_id, service_id, SECRET_KEY)
3. Set the callback URLs in the Click merchant cabinet (merchant.click.uz → Сервисы → pencil icon)
4. The Prepare URL and Complete URL will be provided by the plugin — usually something like:
   - WordPress: `https://your-site.uz/wc-api/click`
   - OpenCart: `https://your-site.uz/index.php?route=extension/payment/click/callback`
5. Request service activation from Click support
6. Test with a small amount payment

## Custom CMS / Framework

If your CMS is not listed, implement the SHOP API manually:
- See `02-shop-api-requests.md` for the full Prepare/Complete specification
- See `14-server-examples.md` for code examples in PHP, Python, Node.js, Go
