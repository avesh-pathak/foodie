import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { db } from './db';
import { restaurants, menuItems, addOns, foodCategories, coupons, adminUsers } from './db/schema';

const seedPath = path.resolve(process.cwd(), 'seed', 'mock_data.json');
const raw = JSON.parse(fs.readFileSync(seedPath, 'utf-8'));

async function main() {
  // food categories
  for (const c of raw.categories) {
    await db.insert(foodCategories).values({
      id: c.id,
      label: c.label,
      icon: 'grid_view_rounded',
      color: '#' + (c.color >>> 0).toString(16).padStart(8, '0').slice(2),
      softColor: '#' + (c.softColor >>> 0).toString(16).padStart(8, '0').slice(2),
    }).onConflictDoNothing();
  }
  // restaurants + menu
  for (const r of raw.restaurants) {
    await db.insert(restaurants).values({
      id: r.id,
      name: r.name,
      tagline: r.tagline,
      description: r.description,
      coverImage: r.coverImage,
      rating: String(r.rating),
      ratingCount: r.ratingCount,
      cuisines: r.cuisines,
      deliveryMinutes: r.deliveryMinutes,
      deliveryFee: String(r.deliveryFee),
      priceForTwo: r.priceForTwo,
      distanceKm: String(r.distanceKm),
      categories: r.categories,
      offer: r.offer,
      menuCategories: r.menuCategories,
      isPromoted: r.isPromoted ?? false,
    }).onConflictDoNothing();
    for (const m of r.menu) {
      await db.insert(menuItems).values({
        id: m.id,
        restaurantId: m.restaurantId,
        name: m.name,
        description: m.description,
        price: String(m.price),
        image: m.image,
        rating: String(m.rating),
        ratingCount: m.ratingCount,
        isVeg: m.isVeg,
        category: m.category,
        homeCategory: m.homeCategory ?? null,
        isBestseller: m.isBestseller ?? false,
        isRecommended: m.isRecommended ?? false,
      }).onConflictDoNothing();
      if (m.addOns?.length) {
        for (const a of m.addOns) {
          await db.insert(addOns).values({ menuItemId: m.id, name: a.name, price: String(a.price) });
        }
      }
    }
  }
  // coupons
  for (const c of raw.coupons) {
    await db.insert(coupons).values({
      id: c.code,
      code: c.code,
      title: c.title,
      description: c.description,
      discount: String(c.value),
      minOrder: String(c.minOrder),
      active: true,
    }).onConflictDoNothing();
  }
  // admin user
  await db.insert(adminUsers).values({ id: 'admin', username: 'admin', passwordHash: 'password123' }).onConflictDoNothing();
  console.log('Seed complete');
  process.exit(0);
}

main().catch((e) => { console.error(e); process.exit(1); });