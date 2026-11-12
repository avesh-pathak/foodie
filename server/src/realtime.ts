import { createRealtime, rawSql } from '@neon/realtime/server';

export type RealtimeEvent = { table: string; payload: unknown; at: string };
const listeners = new Set<(event: RealtimeEvent) => void>();

export function onRealtimeEvent(listener: (event: RealtimeEvent) => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function emit(event: RealtimeEvent) {
  for (const listener of listeners) {
    try {
      listener(event);
    } catch {
      // A dead SSE stream must not stop other listeners.
    }
  }
}

let started = false;

export async function startRealtime() {
  if (started) return;
  started = true;
  const secret = process.env.NEON_REALTIME_SECRET;
  const url = process.env.NEON_REALTIME_URL;
  if (!secret || !url) {
    console.warn('Neon Realtime is not configured (missing secret or URL).');
    return;
  }
  try {
    const realtime = createRealtime({
      secret,
      db: 'neondb',
      url,
      logLevel: 'warn',
    });

    const tables: Array<[string, string]> = [
      ['restaurants', 'select id, name, updated_at from restaurants'],
      ['menu_items', 'select id, restaurant_id, price, is_available, updated_at from menu_items'],
      ['orders', 'select id, status, confirmed_at, ready_at, updated_at from orders'],
    ];

    for (const [table, query] of tables) {
      const sub = await realtime.subscribe(rawSql(query), { materialize: false });
      sub.onUpdate((update) => {
        emit({ table, payload: update, at: new Date().toISOString() });
      });
      sub.onStateChange((state) => {
        console.log(`[realtime] ${table}: ${JSON.stringify(state)}`);
      });
      console.log(`[realtime] subscribed to ${table}`);
    }
  } catch (error) {
    console.error('[realtime] failed to start', error);
  }
}