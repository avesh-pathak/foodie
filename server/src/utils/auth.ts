export function isAdmin(c: any): boolean {
  const auth = c.req.header('authorization') || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : c.req.header('x-admin-token');
  return token === (process.env.ADMIN_TOKEN || 'dev-admin-token');
}