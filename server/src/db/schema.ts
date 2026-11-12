import { pgTable, text, varchar, boolean, integer, numeric, timestamp, jsonb, serial, index } from 'drizzle-orm/pg-core';

export const restaurants = pgTable('restaurants', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  tagline: text('tagline').notNull(),
  description: text('description').notNull(),
  coverImage: text('cover_image').notNull(),
  rating: numeric('rating', { precision: 3, scale: 2 }).notNull().default('0'),
  ratingCount: integer('rating_count').notNull().default(0),
  cuisines: jsonb('cuisines').$type<string[]>().notNull().default([]),
  deliveryMinutes: integer('delivery_minutes').notNull().default(30),
  deliveryFee: numeric('delivery_fee', { precision: 10, scale: 2 }).notNull().default('0'),
  priceForTwo: integer('price_for_two').notNull().default(0),
  distanceKm: numeric('distance_km', { precision: 5, scale: 2 }).notNull().default('0'),
  categories: jsonb('categories').$type<string[]>().notNull().default([]),
  offer: text('offer').notNull().default(''),
  menuCategories: jsonb('menu_categories').$type<string[]>().notNull().default([]),
  isPromoted: boolean('is_promoted').notNull().default(false),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export const menuItems = pgTable('menu_items', {
  id: text('id').primaryKey(),
  restaurantId: text('restaurant_id').notNull().references(() => restaurants.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  description: text('description').notNull(),
  price: numeric('price', { precision: 10, scale: 2 }).notNull(),
  image: text('image').notNull(),
  rating: numeric('rating', { precision: 3, scale: 2 }).notNull().default('0'),
  ratingCount: integer('rating_count').notNull().default(0),
  isVeg: boolean('is_veg').notNull().default(true),
  category: text('category').notNull(),
  homeCategory: text('home_category'),
  isBestseller: boolean('is_bestseller').notNull().default(false),
  isRecommended: boolean('is_recommended').notNull().default(false),
  isAvailable: boolean('is_available').notNull().default(true),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (t) => ({
  restaurantIdx: index('menu_items_restaurant_idx').on(t.restaurantId),
}));

export const addOns = pgTable('add_ons', {
  id: serial('id'),
  menuItemId: text('menu_item_id').notNull().references(() => menuItems.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  price: numeric('price', { precision: 10, scale: 2 }).notNull(),
});

export const foodCategories = pgTable('food_categories', {
  id: text('id').primaryKey(),
  label: text('label').notNull(),
  icon: text('icon').notNull(),
  color: text('color').notNull(),
  softColor: text('soft_color').notNull(),
});

export const coupons = pgTable('coupons', {
  id: text('id').primaryKey(),
  code: text('code').notNull().unique(),
  title: text('title').notNull(),
  description: text('description').notNull(),
  discount: numeric('discount', { precision: 10, scale: 2 }).notNull(),
  minOrder: numeric('min_order', { precision: 10, scale: 2 }).notNull().default('0'),
  active: boolean('active').notNull().default(true),
});

export const customers = pgTable('customers', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  phone: text('phone'),
  email: text('email'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

export const orders = pgTable('orders', {
  id: text('id').primaryKey(),
  customerId: text('customer_id').references(() => customers.id),
  customerName: text('customer_name').notNull(),
  status: text('status').notNull().default('pending'),
  deliveryAddress: text('delivery_address').notNull(),
  locality: text('locality').notNull(),
  pincode: text('pincode'),
  paymentMethod: text('payment_method').notNull(),
  subtotal: numeric('subtotal', { precision: 10, scale: 2 }).notNull(),
  deliveryFee: numeric('delivery_fee', { precision: 10, scale: 2 }).notNull(),
  discount: numeric('discount', { precision: 10, scale: 2 }).notNull().default('0'),
  gst: numeric('gst', { precision: 10, scale: 2 }).notNull().default('0'),
  total: numeric('total', { precision: 10, scale: 2 }).notNull(),
  couponCode: text('coupon_code'),
  confirmedAt: timestamp('confirmed_at'),
  preparingStartedAt: timestamp('preparing_started_at'),
  readyAt: timestamp('ready_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (t) => ({
  statusIdx: index('orders_status_idx').on(t.status),
  localityIdx: index('orders_locality_idx').on(t.locality),
  createdIdx: index('orders_created_idx').on(t.createdAt),
}));

export const orderItems = pgTable('order_items', {
  id: serial('id'),
  orderId: text('order_id').notNull().references(() => orders.id, { onDelete: 'cascade' }),
  menuItemId: text('menu_item_id').notNull(),
  restaurantId: text('restaurant_id').notNull(),
  name: text('name').notNull(),
  price: numeric('price', { precision: 10, scale: 2 }).notNull(),
  quantity: integer('quantity').notNull(),
  isVeg: boolean('is_veg').notNull().default(true),
  addOns: jsonb('add_ons').$type<{ name: string; price: number }[]>().notNull().default([]),
});

export const orderStatusHistory = pgTable('order_status_history', {
  id: serial('id'),
  orderId: text('order_id').notNull().references(() => orders.id, { onDelete: 'cascade' }),
  status: text('status').notNull(),
  changedAt: timestamp('changed_at').notNull().defaultNow(),
});

export const dailySummaries = pgTable('daily_summaries', {
  id: serial('id'),
  date: text('date').notNull(), // YYYY-MM-DD
  restaurantId: text('restaurant_id'),
  locality: text('locality'),
  ordersCount: integer('orders_count').notNull().default(0),
  revenue: numeric('revenue', { precision: 12, scale: 2 }).notNull().default('0'),
  cancelledCount: integer('cancelled_count').notNull().default(0),
  returnedCount: integer('returned_count').notNull().default(0),
  aov: numeric('aov', { precision: 10, scale: 2 }).notNull().default('0'),
}, (t) => ({
  dateIdx: index('daily_summaries_date_idx').on(t.date),
  restaurantIdx: index('daily_summaries_restaurant_idx').on(t.restaurantId),
  localityIdx: index('daily_summaries_locality_idx').on(t.locality),
}));

export const adminUsers = pgTable('admin_users', {
  id: text('id').primaryKey(),
  username: text('username').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

export const kitchenUsers = pgTable('kitchen_users', {
  id: text('id').primaryKey(),
  username: text('username').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  restaurantId: text('restaurant_id').notNull().references(() => restaurants.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});