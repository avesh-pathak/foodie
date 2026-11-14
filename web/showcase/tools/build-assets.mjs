import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const TOOLS = dirname(fileURLToPath(import.meta.url));
const SHOWCASE = resolve(TOOLS, '..');
const REPO = resolve(SHOWCASE, '..', '..');
const OUT_IMG = join(SHOWCASE, 'public', 'assets', 'img', 'screens');
const OUT_FONT = join(SHOWCASE, 'public', 'assets', 'fonts');
const SRC_IMG = join(REPO, 'docs', 'screenshots');
const SRC_FONT = join(REPO, 'assets', 'fonts');

export const screens = [
  // Customer
  { slug: 'welcome', src: 'welcome.png', app: 'customer', title: 'Welcome', alt: 'Foodie welcome screen with a food photo, brand lockup and Get Started button', caption: 'A food-led first screen with one clear action.' },
  { slug: 'login', src: 'login.png', app: 'customer', title: 'Demo login', alt: 'Foodie demo login with name, optional password and a demo details shortcut', caption: 'Any name, phone or email gets in. Password optional.' },
  { slug: 'home', src: 'home.png', app: 'customer', title: 'Home', alt: 'Foodie home screen with delivery address, search, offer carousel and cuisine filters', caption: 'Address, search, offers and cuisine filters.' },
  { slug: 'home-dark', src: 'home-dark.png', app: 'customer', title: 'Home, dark', alt: 'Foodie home screen in the red-on-black dark theme', caption: 'The same home in the red-on-black theme.' },
  { slug: 'search', src: 'search.png', app: 'customer', title: 'Search', alt: 'Search results for biryani across restaurants and dishes', caption: 'Live results across restaurants and dishes.' },
  { slug: 'restaurant', src: 'restaurant.png', app: 'customer', title: 'Restaurant', alt: 'Hyderabadi House restaurant page with hero photo, rating, offer and menu', caption: 'Rating, offer, menu categories and dishes.' },
  { slug: 'menu', src: 'menu.png', app: 'customer', title: 'Menu', alt: 'Restaurant menu with a biryani added to the cart and a View cart bar', caption: 'Add-ons, quantity and a persistent cart bar.' },
  { slug: 'dish-customisation', src: 'dish-customisation.png', app: 'customer', title: 'Dish sheet', alt: 'Dish customisation sheet with add-ons, quantity and special instructions', caption: 'Add-ons, quantity and cooking notes in one sheet.' },
  { slug: 'cart', src: 'cart.png', app: 'customer', title: 'Cart', alt: 'Cart with two dishes, an applied coupon and a live bill total', caption: 'Coupon, GST, delivery fee and a live total.' },
  { slug: 'checkout', src: 'checkout.png', app: 'customer', title: 'Checkout', alt: 'Checkout with a saved address, payment methods and order summary', caption: 'Saved address, payment method and summary.' },
  { slug: 'order-success', src: 'order-success.png', app: 'customer', title: 'Order placed', alt: 'Order placed confirmation with order ID, ETA and tracking action', caption: 'Confetti, haptics and a hand-off to tracking.' },
  { slug: 'orders-active', src: 'orders-active.png', app: 'customer', title: 'Active orders', alt: 'Active order card with live status, progress bar and Track order action', caption: 'Live status and progress at a glance.' },
  { slug: 'tracking', src: 'tracking.png', app: 'customer', title: 'Tracking', alt: 'Live order tracking with a demo neighbourhood map, rider position and six-step timeline', caption: 'A six-step timeline and a hand-drawn demo map.' },
  { slug: 'order-history', src: 'order-history.png', app: 'customer', title: 'History', alt: 'Order history with three past orders and reorder actions', caption: 'Past orders with one-tap reorder.' },
  { slug: 'favorites', src: 'favorites.png', app: 'customer', title: 'Favorites', alt: 'Favorites screen with a saved restaurant', caption: 'Restaurants and dishes kept in sync.' },
  { slug: 'offers', src: 'offers.png', app: 'customer', title: 'Offers', alt: 'Offers and coupons screen with four coupon codes', caption: 'Four demo coupons with eligibility checks.' },
  { slug: 'profile', src: 'profile.png', app: 'customer', title: 'Profile', alt: 'Profile with Foodie Gold, account shortcuts and support links', caption: 'Account, addresses, orders and support.' },
  { slug: 'support', src: 'support.png', app: 'customer', title: 'Support', alt: 'Help and support with chat, call and a frequently asked questions list', caption: 'FAQ accordion and a simulated chat.' },
  { slug: 'settings', src: 'settings.png', app: 'customer', title: 'Settings', alt: 'Settings with notification switches, appearance and demo reset', caption: 'Notifications, appearance and demo reset.' },
  { slug: 'settings-dark', src: 'settings-dark.png', app: 'customer', title: 'Settings, dark', alt: 'Settings screen in the dark red-on-black theme', caption: 'Dark theme in one tap.' },

  // Admin
  { slug: 'admin-login', src: 'admin-login.png', app: 'admin', title: 'Admin login', alt: 'Foodie Admin login screen with logo and demo credentials', caption: 'Demo credentials are printed on the screen.' },
  { slug: 'admin-restaurants', src: 'admin-restaurants.png', app: 'admin', title: 'Restaurants', alt: 'Foodie Admin restaurant list with photos and add action', caption: 'Six stores with covers and quick edit.' },
  { slug: 'admin-menu', src: 'admin-menu.png', app: 'admin', title: 'Menu & prices', alt: 'Foodie Admin menu and price editor with dish thumbnails', caption: 'Edit price, category and photo in place.' },
  { slug: 'admin-edit-menu', src: 'admin-edit-menu.png', app: 'admin', title: 'Edit item', alt: 'Foodie Admin edit menu item dialog with price, category, description and photo preview', caption: 'A dish dialog with a live photo preview.' },
  { slug: 'admin-orders', src: 'admin-orders.png', app: 'admin', title: 'Orders', alt: 'Foodie Admin orders list with status controls', caption: 'Every order with status controls.' },
  { slug: 'admin-analytics', src: 'admin-analytics.png', app: 'admin', title: 'Analytics', alt: 'Foodie Admin analytics dashboard with revenue, orders, AOV and returns', caption: 'Revenue, orders, AOV and returns.' },
  { slug: 'admin-analytics-charts', src: 'admin-analytics-charts.png', app: 'admin', title: 'Charts', alt: 'Foodie Admin analytics charts including orders by area and top restaurants', caption: 'Peak hours, areas and top restaurants.' },

  // Kitchen
  { slug: 'kitchen-login', src: 'kitchen-login.png', app: 'kitchen', title: 'Kitchen login', alt: 'Foodie Kitchen login screen with demo credentials', caption: 'An account bound to one restaurant.' },
  { slug: 'kitchen-orders', src: 'kitchen-orders.png', app: 'kitchen', title: 'Orders board', alt: 'Foodie Kitchen orders board with ready orders and preparation timers', caption: 'Confirmed, preparing and ready, with prep timers.' },
  { slug: 'kitchen-availability', src: 'kitchen-availability.png', app: 'kitchen', title: 'Availability', alt: 'Foodie Kitchen item availability toggles', caption: 'Sold-out toggles reach the customer app.' },
];

function run(args) {
  execFileSync('ffmpeg', args, { stdio: 'inherit' });
}

mkdirSync(OUT_IMG, { recursive: true });
mkdirSync(OUT_FONT, { recursive: true });

const manifest = [];
for (const screen of screens) {
  const src = join(SRC_IMG, screen.src);
  if (!existsSync(src)) throw new Error(`Missing screenshot: ${src}`);
  const thumb = `${screen.slug}.webp`;
  const full = `${screen.slug}@full.webp`;
  run(['-y', '-hide_banner', '-loglevel', 'error', '-i', src, '-vf', 'scale=520:-1', '-c:v', 'libwebp', '-quality', '82', '-compression_level', '6', join(OUT_IMG, thumb)]);
  run(['-y', '-hide_banner', '-loglevel', 'error', '-i', src, '-vf', 'scale=900:-1', '-c:v', 'libwebp', '-quality', '80', '-compression_level', '6', join(OUT_IMG, full)]);
  manifest.push({ ...screen, thumb: `/assets/img/screens/${thumb}`, full: `/assets/img/screens/${full}` });
}

for (const font of ['PlusJakartaSans-Regular.ttf', 'PlusJakartaSans-Medium.ttf', 'PlusJakartaSans-SemiBold.ttf', 'PlusJakartaSans-Bold.ttf', 'PlusJakartaSans-ExtraBold.ttf']) {
  copyFileSync(join(SRC_FONT, font), join(OUT_FONT, font));
}

writeFileSync(join(TOOLS, 'screens.json'), JSON.stringify(manifest, null, 2));
console.log(`Built ${manifest.length} screens, 2 sizes each, in ${OUT_IMG}`);
