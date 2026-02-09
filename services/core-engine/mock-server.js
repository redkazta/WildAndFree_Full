const http = require('http');
const url = require('url');

const PORT = 8080;

// Mock Data
let tags = [
  { id: 1, name: 'FAN', color: 'bg-gray-500', animation: 'pulse' },
  { id: 2, name: 'VIP', color: 'bg-yellow-500', animation: 'bounce' },
  { id: 3, name: 'CREW', color: 'bg-red-600', animation: 'spin' },
  { id: 4, name: 'OG', color: 'bg-purple-600', animation: 'pulse' }
];

let userTags = {
  'user-123': [1, 2], // Admin user has FAN and VIP
  'test-user': [1]
};

// Mock Users (mimicking profiles + roles)
const users = [
  { id: 'user-123', username: 'admin@wildandfree.com', role: 'admin' },
  { id: 'test-user', username: 'fan@wildandfree.com', role: 'fan' },
  { id: 'artist-1', username: 'artist@wildandfree.com', role: 'artist' }
];

const server = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-User-Id');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  console.log(`${req.method} ${path}`);

  // Helper to send JSON
  const sendJSON = (data, status = 200) => {
    res.writeHead(status, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(data));
  };

  // Helper to read body
  const readBody = (callback) => {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      try {
        const data = body ? JSON.parse(body) : {};
        callback(data);
      } catch (e) {
        sendJSON({ error: 'Invalid JSON' }, 400);
      }
    });
  };

  // Router
  if (path === '/api/v1/tags' && req.method === 'GET') {
    return sendJSON({ tags });
  }

  if (path === '/api/v1/tags' && req.method === 'POST') {
    return readBody((data) => {
      const newTag = {
        id: tags.length + 1,
        name: data.name,
        color: data.color,
        animation: data.animation
      };
      tags.push(newTag);
      return sendJSON(newTag);
    });
  }

  if (path.startsWith('/api/v1/tags/') && req.method === 'DELETE') {
    const id = parseInt(path.split('/').pop());
    tags = tags.filter(t => t.id !== id);
    // Also remove from users
    Object.keys(userTags).forEach(uid => {
      userTags[uid] = userTags[uid].filter(tid => tid !== id);
    });
    return sendJSON({ status: 'success' });
  }

  // User Tags
  // Pattern: /api/v1/users/:userId/tags
  if (path.match(/\/api\/v1\/users\/[^\/]+\/tags$/) && req.method === 'GET') {
    const userId = path.split('/')[4]; // /api/v1/users/USERID/tags
    const tagIds = userTags[userId] || [];
    const myTags = tags.filter(t => tagIds.includes(t.id)).map(t => ({
      tag_id: t.id,
      tag_name: t.name,
      color: t.color,
      animation: t.animation
    }));
    return sendJSON({ tags: myTags });
  }

  // Assign Tag
  // Pattern: /api/v1/users/:userId/tags/:tagId
  if (path.match(/\/api\/v1\/users\/[^\/]+\/tags\/\d+$/) && req.method === 'POST') {
    const parts = path.split('/');
    const userId = parts[4];
    const tagId = parseInt(parts[6]);
    
    if (!userTags[userId]) userTags[userId] = [];
    if (!userTags[userId].includes(tagId)) userTags[userId].push(tagId);
    
    return sendJSON({ status: 'success' });
  }

  // Remove Tag
  if (path.match(/\/api\/v1\/users\/[^\/]+\/tags\/\d+$/) && req.method === 'DELETE') {
    const parts = path.split('/');
    const userId = parts[4];
    const tagId = parseInt(parts[6]);
    
    if (userTags[userId]) {
      userTags[userId] = userTags[userId].filter(id => id !== tagId);
    }
    
    return sendJSON({ status: 'success' });
  }

  // Admin: Users with Tags
  if (path === '/api/v1/admin/users-with-tags' && req.method === 'GET') {
    const result = users.map(u => {
      const tagIds = userTags[u.id] || [];
      const uTags = tags.filter(t => tagIds.includes(t.id)).map(t => ({
        tag_id: t.id,
        tag_name: t.name,
        color: t.color,
        animation: t.animation
      }));
      return {
        id: u.id,
        username: u.username,
        role: u.role,
        tags: uTags
      };
    });
    return sendJSON({ users: result }); // Changed to match Go response structure wrapper if any, Go sends array directly? 
    // Wait, Go code: json.NewEncoder(w).Encode(map[string]interface{}{ "users": usersWithTags })
    // So yes, { users: [...] }
  }

  sendJSON({ error: 'Not Found' }, 404);
});

server.listen(PORT, () => {
  console.log(`Mock Core Engine running on port ${PORT}`);
});
