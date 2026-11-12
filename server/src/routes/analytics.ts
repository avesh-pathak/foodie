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

const prepElapsed = sql`EXTRACT(EPOCH FROM (o.ready_at - COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at)))`;

app.get('/prep-time', async (c) => {
  const avgRes = await db.execute(sql`
    SELECT COALESCE(AVG(${prepElapsed}),0)::float AS avg_prep_seconds
    FROM orders o
    WHERE o.ready_at IS NOT NULL
      AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
  `);
  const avgPrepSeconds = Number((avgRes.rows[0] as any)?.avg_prep_seconds ?? 0);

  const byRestaurantRes = await db.execute(sql`
    SELECT oi.restaurant_id AS "restaurantId", r.name AS name,
           COALESCE(AVG(${prepElapsed}),0)::float AS avg
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    LEFT JOIN restaurants r ON r.id = oi.restaurant_id
    WHERE o.ready_at IS NOT NULL
      AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
    GROUP BY oi.restaurant_id, r.name
    ORDER BY avg DESC
  `);

  const byDishRes = await db.execute(sql`
    SELECT oi.name AS name, COALESCE(AVG(${prepElapsed}),0)::float AS avg
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    WHERE o.ready_at IS NOT NULL
      AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
    GROUP BY oi.name
    ORDER BY avg DESC
    LIMIT 20
  `);

  const byHourRes = await db.execute(sql`
    SELECT EXTRACT(HOUR FROM o.ready_at)::int AS hour,
           COALESCE(AVG(${prepElapsed}),0)::float AS avg
    FROM orders o
    WHERE o.ready_at IS NOT NULL
      AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
    GROUP BY hour
    ORDER BY hour
  `);

  const trendRes = await db.execute(sql`
    SELECT to_char(o.ready_at, 'YYYY-MM-DD') AS date,
           COALESCE(AVG(${prepElapsed}),0)::float AS avg
    FROM orders o
    WHERE o.ready_at IS NOT NULL
      AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
    GROUP BY date
    ORDER BY date
  `);

  const slowestRes = await db.execute(sql`
    WITH prepped AS (
      SELECT o.id AS order_id,
             EXTRACT(EPOCH FROM (o.ready_at - COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at)))::int AS elapsed
      FROM orders o
      WHERE o.ready_at IS NOT NULL
        AND COALESCE(o.preparing_started_at, o.confirmed_at, o.created_at) IS NOT NULL
    ),
    first_rest AS (
      SELECT DISTINCT ON (oi.order_id) oi.order_id, r.name AS restaurant
      FROM order_items oi
      LEFT JOIN restaurants r ON r.id = oi.restaurant_id
      ORDER BY oi.order_id, oi.id
    )
    SELECT p.order_id AS "orderId", fr.restaurant AS restaurant, p.elapsed AS elapsed
    FROM prepped p
    LEFT JOIN first_rest fr ON fr.order_id = p.order_id
    ORDER BY p.elapsed DESC
    LIMIT 10
  `);

  return c.json({
    avgPrepSeconds,
    byRestaurant: byRestaurantRes.rows,
    byDish: byDishRes.rows,
    byHour: byHourRes.rows,
    trend: trendRes.rows,
    slowest: slowestRes.rows.map((r: any) => ({
      orderId: r.orderId ?? r.order_id,
      restaurant: r.restaurant,
      elapsed: Number(r.elapsed ?? 0),
    })),
  });
});

app.get('/daily-summary', async (c) => {
  const rows = await db.select().from(dailySummaries);
  return c.json(rows);
});

export default app;
