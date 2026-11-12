import 'dotenv/config';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { streamSSE } from 'hono/streaming';
import { serve } from '@hono/node-server';
import restaurants from './routes/restaurants';
import menu from './routes/menu';
import orders from './routes/orders';
import analytics from './routes/analytics';
import images from './routes/images';
import auth from './routes/auth';
import { onRealtimeEvent, startRealtime } from './realtime';

const app = new Hono();
app.use('*', logger());
app.use('*', cors({ origin: '*' }));

app.get('/health', (c) => c.json({ ok: true }));
app.route('/auth', auth);
app.route('/restaurants', restaurants);
app.route('/menu', menu);
app.route('/orders', orders);
app.route('/analytics', analytics);
app.route('/images', images);

app.get('/events', (c) => {
  return streamSSE(c, async (stream) => {
    let closed = false;
    const unsubscribe = onRealtimeEvent((event) => {
      if (closed) return;
      stream.writeSSE({ event: 'change', data: JSON.stringify(event) }).catch(() => {});
    });
    stream.onAbort(() => {
      closed = true;
      unsubscribe();
    });
    await stream.writeSSE({ event: 'ready', data: JSON.stringify({ ok: true }) });
    while (!closed) {
      await stream.sleep(15000);
      if (!closed) await stream.writeSSE({ event: 'ping', data: '{}' });
    }
  });
});

const port = Number(process.env.PORT || 3001);
serve({ fetch: app.fetch, port }, (info) => {
  console.log(`Server running on http://localhost:${info.port}`);
  startRealtime();
});