const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Greetings from the DevOps Squadron!\n');
});

server.listen(80, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});