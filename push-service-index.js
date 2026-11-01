const express = require('express');
const webpush = require('web-push');
const cors = require('cors');
const { exec } = require('child_process');

const app = express();
app.use(cors());
app.use(express.json());

const PUBLIC_KEY = 'BKAnb5oOPr691scCUtputXeYY2rOP_tIa_ISegWc9w9DrbROrlvM9EMXcw2ssUO9Qb94-cTmDBEKBlbCLxkTBwI';
const PRIVATE_KEY = 'F5kJrKHm7APlsDpPdukOhfuuazfskxRr-upKXymaHTE';

webpush.setVapidDetails(
  'mailto:support@ychat.app',
  PUBLIC_KEY,
  PRIVATE_KEY
);

function getSubscriptionsForUser(username) {
  return new Promise((resolve) => {
    const safeUser = (username || '').replace(/'/g, "''");
    const sql = "SELECT endpoint, p256dh, auth FROM push_subscriptions WHERE LOWER(username) = LOWER('" + safeUser + "')";
    const cmd = "docker exec -i ychatapp_db mysql -u ychat_user -pychat_pass_2026 ychatapp -B -N -e \"" + sql + "\"";
    exec(cmd, (err, stdout) => {
      if (err) {
        console.error('MySQL query error:', err);
        return resolve([]);
      }
      const lines = stdout.trim().split('\n').filter(Boolean);
      const subs = [];
      for (const line of lines) {
        const parts = line.split('\t');
        if (parts.length >= 3) {
          subs.push({
            endpoint: parts[0],
            keys: { p256dh: parts[1], auth: parts[2] }
          });
        }
      }
      resolve(subs);
    });
  });
}

function removeBadSubscription(endpoint) {
  const safeEp = (endpoint || '').replace(/'/g, "''");
  const sql = "DELETE FROM push_subscriptions WHERE endpoint = '" + safeEp + "'";
  exec("docker exec -i ychatapp_db mysql -u ychat_user -pychat_pass_2026 ychatapp -e \"" + sql + "\"");
}

app.get('/vapid-public-key', (req, res) => {
  res.json({ publicKey: PUBLIC_KEY });
});

app.post('/notify-user', async (req, res) => {
  const { username, payload } = req.body;
  if (!username) return res.status(400).json({ error: 'Username required' });
  const subs = await getSubscriptionsForUser(username);
  console.log(new Date().toISOString(), 'Sending push to ' + username + ' (' + subs.length + ' devices)...', payload);

  const results = await Promise.allSettled(
    subs.map(async sub => {
      try {
        const r = await webpush.sendNotification(sub, JSON.stringify(payload), {
          TTL: 60,
          urgency: 'high'
        });
        console.log('Push sent successfully to ' + username + ' endpoint, status:', r.statusCode);
        return r;
      } catch (err) {
        console.error('Push error for ' + username + ':', err.statusCode, err.body || err.message);
        if (err.statusCode === 404 || err.statusCode === 410) {
          console.log('Expired subscription, removing:', sub.endpoint);
          removeBadSubscription(sub.endpoint);
        }
        throw err;
      }
    })
  );

  res.json({ sent: results.filter(r => r.status === 'fulfilled').length, total: subs.length });
});

app.listen(3001, '0.0.0.0', () => {
  console.log('Push service listening on port 3001');
});
