import { Hono } from 'hono';
import { z } from 'zod';
import { db } from '../db';
import { restaurants } from '../db/schema';
import { eq } from 'drizzle-orm';
import { isAdmin } from '../utils/auth';

const app = new Hono();

const restaurantSchema = z.object({
  id: z.string().optional(),
  name: z.string(),
  tagline: z.string().default(''),
  description: z.string().default(''),
  coverImage: z.string().default(''),
  rating: z.number().default(0),
  ratingCount: z.number().int().default(0),
  cuisines: z.array(z.string()).default([]),
  deliveryMinutes: z.number().int().default(30),
  deliveryFee: z.number().default(0),
  priceForTwo: z.number().int().default(0),
  distanceKm: z.number().default(0),
  categories: z.array(z.string()).default([]),
  offer: z.string().default(''),
  menuCategories: z.array(z.string()).default([]),
  isPromoted: z.boolean().default(false),
});

app.get('/', async (c) => {
  const rows = await db.select().from(restaurants);
  return c.json(rows);
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');
  const rows = await db.select().from(restaurants).where(eq(restaurants.id, id));
  if (!rows.length) return c.json({ error: 'not found' }, 404);
  return c.json(rows[0]);
});

app.post('/', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const body = await c.req.json();
  const parsed = restaurantSchema.parse(body);
  const id = parsed.id || `r_${Date.now()}`;
  const [row] = await db.insert(restaurants).values({ ...parsed, id }).returning();
  return c.json(row, 201);
});

app.put('/:id', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const id = c.req.param('id');
  const body = await c.req.json();
  const parsed = restaurantSchema.partial().parse(body);
  const [row] = await db.update(restaurants).set({ ...parsed, updatedAt: new Date() }).where(eq(restaurants.id, id)).returning();
  if (!row) return c.json({ error: 'not found' }, 404);
  return c.json(row);
});

app.delete('/:id', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const id = c.req.param('id');
  await db.delete(restaurants).where(eq(restaurants.id, id));
  return c.json({ ok: true });
});

export default app;