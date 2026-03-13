import { Router } from 'express';
import { query } from '../db';

const router = Router();

router.get('/categories', async (req, res) => {
  const result = await query('SELECT id, name FROM marketplace_categories ORDER BY name');
  return res.json(result.rows);
});

router.get('/feeds', async (req, res) => {
  const category = req.query.category as string | undefined;
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(100, Number(req.query.limit) || 20);
  const offset = (page - 1) * limit;

  const params: any[] = [limit, offset];
  let sql = 'SELECT id, title, url, description, icon_url FROM marketplace_feeds';

  if (category) {
    sql += ' WHERE category_id = (SELECT id FROM marketplace_categories WHERE name = $3 LIMIT 1)';
    params.push(category);
  }

  sql += ' ORDER BY title LIMIT $1 OFFSET $2';

  const result = await query(sql, params);
  const countResult = await query('SELECT COUNT(*) FROM marketplace_feeds');
  const total = Number(countResult.rows[0].count);

  return res.json({ feeds: result.rows, total });
});

export default router;
