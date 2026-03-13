import dotenv from 'dotenv';
import path from 'path';

const envFile = process.env.NODE_ENV === 'test' ? '.env.test' : '.env';
dotenv.config({ path: path.resolve(process.cwd(), envFile) });

export const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
export const JWT_SECRET = process.env.JWT_SECRET || 'please-change-me';
export const DATABASE_URL = process.env.DATABASE_URL || 'postgres://localhost:5432/aware';
