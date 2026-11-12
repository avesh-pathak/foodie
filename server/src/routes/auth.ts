import { Hono } from 'hono';
import { z } from 'zod';
import { db } from '../db';
import { adminUsers, kitchenUsers } from '../db/schema';
import { eq } from 'drizzle-orm';

const app = new Hono();

const loginSchema = z.object({
  username: z.string(),
  password: z.string(),
});

function adminToken() { return process.env.ADMIN_TOKEN || 'dev-admin-token'; }
function kitchenToken() { return process.env.KITCHEN_TOKEN || 'dev-kitchen-token'; }

app.post('/login', async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const parsed = loginSchema.safeParse(body);
  if (!parsed.success) return c.json({ error: 'invalid body' }, 400);
  const { username, password } = parsed.data;

  // admin
  const adminUsername = process.env.ADMIN_USERNAME || 'admin';
  const adminPassword = process.env.ADMIN_PASSWORD || 'password123';
  if (username === adminUsername && password === adminPassword) {
    return c.json({ token: adminToken(), username, role: 'admin' });
  }
  // check db admin users
  const admins = await db.select().from(adminUsers).where(eq(adminUsers.username, username));
  if (admins.length && admins[0].passwordHash === password) {
    return c.json({ token: adminToken(), username, role: 'admin' });
  }
  // kitchen (env default)
  const kitchenUsername = process.env.KITCHEN_USERNAME || 'kitchen';
  const kitchenPassword = process.env.KITCHEN_PASSWORD || 'password123';
  if (username === kitchenUsername && password === kitchenPassword) {
    // resolve restaurant from seeded kitchen user if present
    const ks = await db.select().from(kitchenUsers).where(eq(kitchenUsers.username, username));
    const restaurantId = ks.length ? ks[0].restaurantId : null;
    return c.json({ token: kitchenToken(), username, role: 'kitchen', restaurantId });
  }
  // db kitchen users
  const kitchens = await db.select().from(kitchenUsers).where(eq(kitchenUsers.username, username));
  if (kitchens.length && kitchens[0].passwordHash === password) {
    return c.json({ token: kitchenToken(), username, role: 'kitchen', restaurantId: kitchens[0].restaurantId });
  }
  return c.json({ error: 'invalid credentials' }, 401);
});

app.get('/me', async (c) => {
  const auth = c.req.header('authorization') || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : c.req.header('x-admin-token');
  if (token === adminToken()) {
    return c.json({ username: process.env.ADMIN_USERNAME || 'admin', role: 'admin', restaurantId: null });
  }
  if (token === kitchenToken()) {
    const ks = await db.select().from(kitchenUsers).where(eq(kitchenUsers.username, process.env.KITCHEN_USERNAME || 'kitchen'));
    const restaurantId = ks.length ? ks[0].restaurantId : null;
    return c.json({ username: process.env.KITCHEN_USERNAME || 'kitchen', role: 'kitchen', restaurantId });
  }
  return c.json({ error: 'unauthorized' }, 401);
});

export default app;
