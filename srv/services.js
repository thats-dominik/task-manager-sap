const cds = require('@sap/cds');
const { SELECT } = cds;
const LOG = cds.log('tasks');

// Expose a basic health endpoint for production environments
cds.on('bootstrap', (app) => {
  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });
});

module.exports = (srv) => {
  const { Tasks } = srv.entities;

  // gilt für alle Services, in denen 'Tasks' projiziert ist
  srv.before('CREATE', 'Tasks', (req) => {
    const t = req.data;
    const title = (t.title || '').toLowerCase();
    if (title.includes('urgent') || title.includes('dringend')) {
      t.urgency_code = 'H'; // überschreibt Default
    }
  });

  srv.before('UPDATE', 'Tasks', async (req) => {
    const { ID } = req.data || {};
    try {
      if (!ID) return;

      const row = await SELECT.one.from(Tasks).columns('status_code').where({ ID });
      if (row?.status_code === 'D') {
        req.reject(400, "can't modify a completed task");
      }
    } catch (error) {
      LOG.error(`Error validating task update for ID ${ID}`, error);
      req.reject(500, 'Error while validating task update');
    }
  });
};
