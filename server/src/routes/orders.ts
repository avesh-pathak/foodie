import { Hono } from 'hono';
import { z } from 'zod';
import { db } from '../db';
import { orders, orderItems, orderStatusHistory, dailySummaries, customers } from '../db/schema';
import { eq, and, sql } from 'drizzle-orm';
import { isAdmin } from '../utils/auth';

const app = new Hono();

const orderSchema = z.object({
  id: z.string().optional(),
  customerId: z.string().nullish(),
  customerName: z.string(),
  deliveryAddress: z.string(),
  locality: z.string(),
  pincode: z.string().nullish(),
  paymentMethod: z.string(),
  subtotal: z.number(),
  deliveryFee: z.number(),
  discount: z.number().default(0),
  gst: z.number().default(0),
  total: z.number(),
  couponCode: z.string().nullish(),
  items: z.array(z.object({
    menuItemId: z.string(),
    restaurantId: z.string(),
    name: z.string(),
    price: z.number(),
    quantity: z.number().int(),
    isVeg: z.boolean().default(true),
    addOns: z.array(z.object({ name: z.string(), price: z.number() })).default([]),
  })),
});

async function upsertSummary(order: any, status: string) {
  const date = new Date().toISOString().slice(0, 10);
  const restaurantIds = Array.from(new Set(order.items.map((i: any) => i.restaurantId)));
  for (const rid of restaurantIds) {
    const existing = await db.select().from(dailySummaries).where(
      and(eq(dailySummaries.date, date), eq(dailySummaries.restaurantId, rid as string), eq(dailySummaries.locality, order.locality))
    );
    const isCancelled = status === 'cancelled';
    const isReturned = status === 'returned';
    if (existing.length) {
      const e = existing[0];
      await db.update(dailySummaries).set({
        ordersCount: e.ordersCount + 1,
        revenue: String(Number(e.revenue) + (isCancelled || isReturned ? 0 : order.total)),
        cancelledCount: e.cancelledCount + (isCancelled ? 1 : 0),
        returnedCount: e.returnedCount + (isReturned ? 1 : 0),
        aov: String(((Number(e.revenue) + (isCancelled || isReturned ? 0 : order.total)) / (e.ordersCount + 1)).toFixed(2)),
      }).where(eq(dailySummaries.id, e.id));
    } else {
      await db.insert(dailySummaries).values({
        date,
        restaurantId: rid as string,
        locality: order.locality,
        ordersCount: 1,
        revenue: isCancelled || isReturned ? '0' : String(order.total),
        cancelledCount: isCancelled ? 1 : 0,
        returnedCount: isReturned ? 1 : 0,
        aov: isCancelled || isReturned ? '0' : String(order.total),
      });
    }
  }
}

app.get('/', async (c) => {
  const status = c.req.query('status');
  let rows = await db.select().from(orders);
  if (status) rows = rows.filter((r) => r.status === status);
  return c.json(rows);
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');
  const rows = await db.select().from(orders).where(eq(orders.id, id));
  if (!rows.length) return c.json({ error: 'not found' }, 404);
  const items = await db.select().from(orderItems).where(eq(orderItems.orderId, id));
  const history = await db.select().from(orderStatusHistory).where(eq(orderStatusHistory.orderId, id));
  return c.json({ ...rows[0], items, history });
});

app.post('/', async (c) => {
  const body = await c.req.json();
  const parsed = orderSchema.parse(body);
  const id = parsed.id || `o_${Date.now()}`;
  if (parsed.customerId) {
    const existing = await db.select().from(customers).where(eq(customers.id, parsed.customerId));
    if (!existing.length) {
      await db.insert(customers).values({ id: parsed.customerId, name: parsed.customerName });
    }
  }
  const [row] = await db.insert(orders).values({
    id,
    customerId: parsed.customerId,
    customerName: parsed.customerName,
    status: 'pending',
    deliveryAddress: parsed.deliveryAddress,
    locality: parsed.locality,
    pincode: parsed.pincode,
    paymentMethod: parsed.paymentMethod,
    subtotal: String(parsed.subtotal),
    deliveryFee: String(parsed.deliveryFee),
    discount: String(parsed.discount),
    gst: String(parsed.gst),
    total: String(parsed.total),
    couponCode: parsed.couponCode,
  }).returning();
  await db.insert(orderItems).values(parsed.items.map((it) => ({
    orderId: id,
    menuItemId: it.menuItemId,
    restaurantId: it.restaurantId,
    name: it.name,
    price: String(it.price),
    quantity: it.quantity,
    isVeg: it.isVeg,
    addOns: it.addOns,
  })));
  await db.insert(orderStatusHistory).values({ orderId: id, status: 'pending' });
  await upsertSummary({ ...parsed, total: parsed.total, items: parsed.items }, 'pending');
  return c.json(row, 201);
});

app.put('/:id/status', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const id = c.req.param('id');
  const body = await c.req.json();
  const status = body.status;
  const [row] = await db.update(orders).set({ status, updatedAt: new Date() }).where(eq(orders.id, id)).returning();
  if (!row) return c.json({ error: 'not found' }, 404);
  await db.insert(orderStatusHistory).values({ orderId: id, status });
  return c.json(row);
});

export default app;