const http = require('http');

const artists = [
  {
    id: 'a1',
    name: 'Nova K',
    role: 'Rapper',
    image_url: 'https://images.unsplash.com/photo-1520975958221-7f61d4d6df4b?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'a2',
    name: 'Sable',
    role: 'Producer',
    image_url: 'https://images.unsplash.com/photo-1520975693413-35e0000c0e4e?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'a3',
    name: 'Mira V',
    role: 'DJ',
    image_url: 'https://images.unsplash.com/photo-1520975753545-c9a7d1551b77?auto=format&fit=crop&w=800&q=80',
  },
];

const health = {
  status: 'live',
  engine: 'Go (Mock)',
  crew: 'Wild and Free',
  timestamp: new Date().toISOString(),
};

const tenantInit = {
  config: {
    id: 'wild-and-free',
    name: 'Wild and Free',
    primary_color: '#00FF41',
    secondary_color: '#0a0a0a',
    modules: { wallet: true, events: true },
  },
  data: {
    crew_name: 'Wild and Free',
  },
};

const server = http.createServer((req, res) => {
  console.log(`[Mock Go] ${req.method} ${req.url}`);
  
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'GET' && req.url === '/api/v1/artists') {
    res.end(JSON.stringify(artists));
    return;
  }

  if (req.method === 'GET' && req.url === '/api/v1/health') {
    res.end(JSON.stringify(health));
    return;
  }

  if (req.method === 'GET' && req.url.match(/^\/api\/v1\/tenant\/[^/]+\/init$/)) {
     res.end(JSON.stringify(tenantInit));
     return;
  }

  res.statusCode = 404;
  res.end(JSON.stringify({ error: 'Not Found' }));
});

server.listen(8080, '127.0.0.1', () => {
  console.log('Mock Core Engine (Go) listening on http://127.0.0.1:8080');
});
