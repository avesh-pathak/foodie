import { eq } from 'drizzle-orm';
import { db } from '../db';
import { kitchenUsers } from '../db/schema';

export function isAdmin(c: any): boolean {
  const auth = c.req.header('authorization') || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : c.req.header('x-admin-token');
  return token === (process.env.ADMIN_TOKEN || 'dev-admin-token');
}

export function isKitchen(c: any): boolean {
  const auth = c.req.header('authorization') || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : c.req.header('x-admin-token');
  return token === (process.env.KITCHEN_TOKEN || 'dev-kitchen-token');
}

export function isStaff(c: any): boolean {
  return isAdmin(c) || isKitchen(c);
}

export async function kitchenRestaurantId(): Promise<string | null> {
  const username = process.env.KITCHEN_USERNAME || 'kitchen';
  const rows = await db.select().from(kitchenUsers).where(eq(kitchenUsers.username, username));
  return rows.length ? rows[0].restaurantId : null;
}