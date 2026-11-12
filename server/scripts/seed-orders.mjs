import 'dotenv/config';
import pg from 'pg';

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

const ordersSql = `
WITH ins AS (
  INSERT INTO orders (id, customer_name, status, delivery_address, locality, payment_method, subtotal, delivery_fee, discount, gst, total, created_at)
  SELECT
    'seed_order_' || g,
    (ARRAY['Aarav','Diya','Kabir','Meera','Rohan','Sana','Vihaan','Isha','Neha','Arjun'])[1 + (g % 10)],
    (ARRAY['delivered','delivered','delivered','cancelled','returned','pending','confirmed'])[1 + (g % 7)],
    'Demo address ' || g,
    (ARRAY['Koramangala','Indiranagar','HSR Layout','Jayanagar','Whitefield','Marathahalli','Bellandur'])[1 + (g % 7)],
    (ARRAY['UPI','Cash on Delivery','Card'])[1 + (g % 3)],
    (180 + (g * 23) % 620)::numeric,
    29,
    CASE WHEN g % 9 = 0 THEN 100 ELSE 0 END,
    (14 + (g * 7) % 55)::numeric,
    (220 + (g * 23) % 620)::numeric,
    (date_trunc('day', now()) - ((g * 3) || ' days')::interval + ((8 + (g % 12)) || ' hours')::interval)
  FROM generate_series(1, 60) AS g
  ON CONFLICT (id) DO NOTHING
  RETURNING id
)
SELECT count(*) FROM ins;
`;

const itemsSql = `
INSERT INTO order_items (order_id, menu_item_id, restaurant_id, name, price, quantity, is_veg, add_ons)
SELECT o.id, m.id, m.restaurant_id, m.name, m.price, 1 + (row_number() OVER (PARTITION BY o.id ORDER BY m.id) % 3), m.is_veg, '[]'::jsonb
FROM orders o
JOIN LATERAL (
  SELECT id, restaurant_id, name, price, is_veg FROM menu_items ORDER BY md5(o.id || id) LIMIT 3
) m ON true
WHERE o.id LIKE 'seed_order_%'
  AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
RETURNING id;
`;

const orders = await client.query(ordersSql);
const items = await client.query(itemsSql);
console.log(`Seeded ${orders.rows[0].count} orders and ${items.rowCount} order items.`);
await client.end();