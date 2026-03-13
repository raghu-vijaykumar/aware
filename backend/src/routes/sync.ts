import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import { query } from '../db';

const router = Router();

router.get('/changes', requireAuth, async (req, res) => {
  const lastSync = req.query.lastSync as string | undefined;
  const userId = (req as any).userId as string;

  const sql = `
    SELECT article_guid, read_at, starred_at
    FROM user_sync_state
    WHERE user_id = $1
      AND ($2::timestamp IS NULL OR GREATEST(read_at, starred_at) > $2::timestamp)
  `;

  const result = await query(sql, [userId, lastSync]);
  return res.json({ readStates: result.rows });
});

router.post('/state', requireAuth, async (req, res) => {
  const userId = (req as any).userId as string;
  const { read = [], starred = [] } = req.body as {
    read?: string[];
    starred?: string[];
  };

  const now = new Date().toISOString();
  const queries = [] as Promise<any>[];

  for (const guid of read) {
    queries.push(
      query(
        `INSERT INTO user_sync_state (user_id, article_guid, read_at)
         VALUES ($1, $2, $3)
         ON CONFLICT (user_id, article_guid)
         DO UPDATE SET read_at = EXCLUDED.read_at`,
        [userId, guid, now],
      ),
    );
  }

  for (const guid of starred) {
    queries.push(
      query(
        `INSERT INTO user_sync_state (user_id, article_guid, starred_at)
         VALUES ($1, $2, $3)
         ON CONFLICT (user_id, article_guid)
         DO UPDATE SET starred_at = EXCLUDED.starred_at`,
        [userId, guid, now],
      ),
    );
  }

  await Promise.all(queries);
  return res.json({ success: true });
});

export default router;
