import request from 'supertest';
import app from '../src/index';

describe('Backend API', () => {
  it('responds to GET / with status 200 and ok body', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});
