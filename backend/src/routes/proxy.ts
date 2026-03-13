import { Router } from 'express';

const router = Router();

router.get('/feed', async (req, res) => {
  const url = req.query.url as string | undefined;
  if (!url) {
    return res.status(400).json({ error: 'Missing url query parameter' });
  }

  try {
    const response = await fetch(url, { timeout: 15000 });
    const text = await response.text();
    res.header('Content-Type', 'application/xml');
    return res.send(text);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch feed' });
  }
});

export default router;
