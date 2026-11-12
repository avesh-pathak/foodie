import { Hono } from 'hono';
import { z } from 'zod';
import { db } from '../db';
import { menuItems, addOns } from '../db/schema';
import { eq } from 'drizzle-orm';
import { isAdmin, isKitchen, isStaff, kitchenRestaurantId } from '../utils/auth';

const app = new Hono();

const itemSchema = z.object({
  id: z.string().optional(),
  restaurantId: z.string(),
  name: z.string(),
  description: z.string().default(''),
  price: z.number(),
  image: z.string().default(''),
  rating: z.number().default(0),
  ratingCount: z.number().int().default(0),
  isVeg: z.boolean().default(true),
  category: z.string(),
  homeCategory: z.string().nullable().optional(),
  isBestseller: z.boolean().default(false),
  isRecommended: z.boolean().default(false),
  isAvailable: z.boolean().default(true),
  addOns: z.array(z.object({ name: z.string(), price: z.number() })).default([]),
});

app.get('/', async (c) => {
  const restaurantId = c.req.query('restaurantId');
  let rows = await db.select().from(menuItems);
  if (restaurantId) rows = rows.filter((r) => r.restaurantId === restaurantId);
  const withAddons = await Promise.all(rows.map(async (item) => {
    const aos = await db.select().from(addOns).where(eq(addOns.menuItemId, item.id));
    return { ...item, price: Number(item.price), addOns: aos.map((a) => ({ name: a.name, price: Number(a.price) })) };
  }));
  return c.json(withAddons);
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');
  const rows = await db.select().from(menuItems).where(eq(menuItems.id, id));
  if (!rows.length) return c.json({ error: 'not found' }, 404);
  const aos = await db.select().from(addOns).where(eq(addOns.menuItemId, id));
  return c.json({ ...rows[0], price: Number(rows[0].price), addOns: aos.map((a) => ({ name: a.name, price: Number(a.price) })) });
});

app.post('/', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const body = await c.req.json();
  const parsed = itemSchema.parse(body);
  const id = parsed.id || `m_${Date.now()}`;
  const { addOns: aos, ...rest } = parsed;
  const [row] = await db.insert(menuItems).values({ ...rest, price: String(rest.price), rating: String(rest.rating), id }).returning();
  if (aos?.length) {
    await db.insert(addOns).values(aos.map((a) => ({ menuItemId: id, name: a.name, price: String(a.price) })));
  }
  return c.json({ ...row, price: Number(row.price), addOns: aos }, 201);
});

app.put('/:id', async (c) => {
  if (!isStaff(c)) return c.json({ error: 'unauthorized' }, 401);
  const id = c.req.param('id');
  const body = await c.req.json();
  const parsed = itemSchema.partial().parse(body);
  // kitchen scope check
  if (isKitchen(c) && !isAdmin(c)) {
    const rows = await db.select().from(menuItems).where(eq(menuItems.id, id));
    if (!rows.length) return c.json({ error: 'not found' }, 404);
    const krid = await kitchenRestaurantId();
    if (!krid || rows[0].restaurantId !== krid) return c.json({ error: 'forbidden' }, 403);
  }
  const { addOns: aos, ...rest } = parsed;
  const update: any = { ...rest, updatedAt: new Date() };
  if (rest.price !== undefined) update.price = String(rest.price);
  const [row] = await db.update(menuItems).set(update).where(eq(menuItems.id, id)).returning();
  if (!row) return c.json({ error: 'not found' }, 404);
  if (aos) {
    await db.delete(addOns).where(eq(addOns.menuItemId, id));
    if (aos.length) await db.insert(addOns).values(aos.map((a) => ({ menuItemId: id, name: a.name, price: String(a.price) })));
  }
  return c.json({ ...row, price: Number(row.price), addOns: aos ?? [] });
});

app.delete('/:id', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const id = c.req.param('id');
  await db.delete(menuItems).where(eq(menuItems.id, id));
  return c.json({ ok: true });
});

export default app;
