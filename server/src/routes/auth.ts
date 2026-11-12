import { Hono } from 'hono';
import { z } from 'zod';

const app = new Hono();

const loginSchema = z.object({
  username: z.string(),
  password: z.string(),
});

app.post('/login', async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const parsed = loginSchema.safeParse(body);
  if (!parsed.success) return c.json({ error: 'invalid body' }, 400);
  const { username, password } = parsed.data;
  if (username !== (process.env.ADMIN_USERNAME || 'admin') || password !== (process.env.ADMIN_PASSWORD || 'password123')) {
    return c.json({ error: 'invalid credentials' }, 401);
  }
  return c.json({ token: process.env.ADMIN_TOKEN || 'dev-admin-token', username });
});

export default app;