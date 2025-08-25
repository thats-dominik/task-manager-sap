const cds = require('@sap/cds');
const { SELECT } = cds;

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
    if (!ID) return;

    const row = await SELECT.one.from(Tasks).columns('status_code').where({ ID });
    if (row?.status_code === 'D') {
      req.reject(400, "can't modify a completed task");
    }
  });
};
