import express from 'express';
import cors from 'cors';
import { PORT } from './env';
import authRoutes from './routes/auth';
import marketplaceRoutes from './routes/marketplace';
import syncRoutes from './routes/sync';
import proxyRoutes from './routes/proxy';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/marketplace', marketplaceRoutes);
app.use('/sync', syncRoutes);
app.use('/proxy', proxyRoutes);

app.get('/', (_req, res) => {
  res.json({ status: 'ok' });
});

// Only start the server when this file is executed directly.
// This keeps the app usable in tests without starting a real listener.
if (require.main === module) {
  app.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`aware backend listening on http://localhost:${PORT}`);
  });
}

export default app;
