import { Hono } from 'hono';
import { db } from '../db';
import { orders, orderItems, dailySummaries } from '../db/schema';
import { sql } from 'drizzle-orm';

const app = new Hono();

app.get('/overview', async (c) => {
  const res = await db.execute(sql`
    SELECT
      COUNT(*)::int AS total_orders,
      COALESCE(SUM(total::numeric),0)::text AS total_revenue,
      COALESCE(AVG(total::numeric),0)::text AS aov,
      COUNT(*) FILTER (WHERE status='cancelled')::int AS cancelled,
      COUNT(*) FILTER (WHERE status='returned')::int AS returned
    FROM orders
  `);
  return c.json(res.rows[0] ?? {});
});

app.get('/by-area', async (c) => {
  const __res = await db.execute(sql`
    SELECT locality, COUNT(*)::int AS orders, COALESCE(SUM(total::numeric),0)::text AS revenue
    FROM orders GROUP BY locality ORDER BY orders DESC
  `);
  return c.json(__res.rows);
});

app.get('/by-restaurant', async (c) => {
  const __res = await db.execute(sql`
    SELECT oi.restaurant_id, r.name, COUNT(DISTINCT o.id)::int AS orders,
           COALESCE(SUM(oi.price::numeric * oi.quantity),0)::text AS revenue
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    LEFT JOIN restaurants r ON r.id = oi.restaurant_id
    GROUP BY oi.restaurant_id, r.name ORDER BY revenue DESC
  `);
  return c.json(__res.rows);
});

app.get('/top-dishes', async (c) => {
  const __res = await db.execute(sql`
    SELECT name, SUM(quantity)::int AS qty, COALESCE(SUM(price::numeric * quantity),0)::text AS revenue
    FROM order_items GROUP BY name ORDER BY qty DESC LIMIT 20
  `);
  return c.json(__res.rows);
});

app.get('/peak-hours', async (c) => {
  const __res = await db.execute(sql`
    SELECT EXTRACT(HOUR FROM created_at)::int AS hour, COUNT(*)::int AS orders
    FROM orders GROUP BY hour ORDER BY hour
  `);
  return c.json(__res.rows);
});

app.get('/by-weekday', async (c) => {
  const __res = await db.execute(sql`
    SELECT EXTRACT(DOW FROM created_at)::int AS dow, COUNT(*)::int AS orders,
           COALESCE(SUM(total::numeric),0)::text AS revenue
    FROM orders GROUP BY dow ORDER BY dow
  `);
  return c.json(__res.rows);
});

app.get('/by-month', async (c) => {
  const __res = await db.execute(sql`
    SELECT to_char(created_at, 'YYYY-MM') AS month, COUNT(*)::int AS orders,
           COALESCE(SUM(total::numeric),0)::text AS revenue
    FROM orders GROUP BY month ORDER BY month
  `);
  return c.json(__res.rows);
});

app.get('/daily-summary', async (c) => {
  const rows = await db.select().from(dailySummaries);
  return c.json(__res.rows);
});

export default app;
