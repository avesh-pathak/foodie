import { Hono } from 'hono';
import { z } from 'zod';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { isAdmin } from '../utils/auth';

const app = new Hono();

const s3 = new S3Client({
  region: process.env.AWS_REGION || 'ap-southeast-1',
  endpoint: process.env.AWS_ENDPOINT_URL_S3,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
  },
  forcePathStyle: true,
});

const schema = z.object({
  key: z.string(),
  contentType: z.string().default('image/jpeg'),
});

app.post('/presign', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const body = await c.req.json();
  const parsed = schema.parse(body);
  const bucket = process.env.S3_BUCKET || 'foodie';
  const cmd = new PutObjectCommand({ Bucket: bucket, Key: parsed.key, ContentType: parsed.contentType });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 300 });
  const origin = process.env.PUBLIC_BASE_URL || new URL(c.req.url).origin;
  const publicUrl = `${origin}/images/object?key=${encodeURIComponent(parsed.key)}`;
  return c.json({ uploadUrl: url, publicUrl });
});

const uploadSchema = z.object({
  key: z.string(),
  contentType: z.string().default('image/jpeg'),
  data: z.string(),
});

app.post('/upload', async (c) => {
  if (!isAdmin(c)) return c.json({ error: 'unauthorized' }, 401);
  const body = await c.req.json();
  const parsed = uploadSchema.parse(body);
  const bucket = process.env.S3_BUCKET || 'foodie';
  await s3.send(new PutObjectCommand({
    Bucket: bucket,
    Key: parsed.key,
    ContentType: parsed.contentType,
    Body: Buffer.from(parsed.data, 'base64'),
  }));
  const origin = process.env.PUBLIC_BASE_URL || new URL(c.req.url).origin;
  return c.json({ publicUrl: `${origin}/images/object?key=${encodeURIComponent(parsed.key)}` });
});

app.get('/object', async (c) => {
  const key = c.req.query('key');
  if (!key) return c.json({ error: 'key required' }, 400);
  try {
    const bucket = process.env.S3_BUCKET || 'foodie';
    const object = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
    return new Response(object.Body as ReadableStream, {
      headers: {
        'Content-Type': object.ContentType || 'application/octet-stream',
        'Cache-Control': 'public, max-age=31536000, immutable',
      },
    });
  } catch {
    return c.json({ error: 'not found' }, 404);
  }
});

export default app;