import { Pool } from 'pg';
import { DATABASE_URL } from './env';

export const pool = new Pool({
  connectionString: DATABASE_URL,
});

export async function query<T = any>(text: string, params?: any[]) {
  const result = await pool.query<T>(text, params);
  return result;
}
