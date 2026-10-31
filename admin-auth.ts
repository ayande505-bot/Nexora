import { createHmac, timingSafeEqual } from 'node:crypto';

const COOKIE_NAME = 'nexora_admin';
const TOKEN_PAYLOAD = 'nexora-admin-v1';

function secret() {
  return process.env.ADMIN_CODE ?? '';
}

export function createAdminToken() {
  const key = secret();
  if (!key) return '';
  return createHmac('sha256', key).update(TOKEN_PAYLOAD).digest('hex');
}

export function isAdminTokenValid(token: string | undefined) {
  const expected = createAdminToken();
  if (!token || !expected) return false;
  const a = Buffer.from(token);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

export { COOKIE_NAME };
