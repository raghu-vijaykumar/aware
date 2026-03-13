import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../db';
import { JWT_SECRET } from '../env';

const router = Router();

router.post('/register', async (req, res) => {
  const { email, password } = req.body as { email: string; password: string };
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const hashed = await bcrypt.hash(password, 10);
  const insert = await query(
    'INSERT INTO users (email, password_hash) VALUES ($1, $2) RETURNING id, email, created_at, updated_at',
    [email, hashed],
  );

  const user = insert.rows[0];
  const token = jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: '7d' });
  return res.json({ token, user });
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body as { email: string; password: string };
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const result = await query('SELECT id, email, password_hash FROM users WHERE email = $1', [email]);
  const user = result.rows[0];

  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: '7d' });
  return res.json({ token, user: { id: user.id, email: user.email } });
});

router.post('/refresh', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET) as { sub: string };
    const newToken = jwt.sign({ sub: payload.sub }, JWT_SECRET, { expiresIn: '7d' });
    return res.json({ token: newToken });
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
});

export default router;
