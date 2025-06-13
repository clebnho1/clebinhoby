import { createServer } from 'http';

const server = createServer((req, res) => {
  // Log da requisição para depuração
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  
  // Rota principal
  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Servidor HTTP funcionando!');
    return;
  }
  
  // Rota de status da API
  if (req.url === '/api/status') {
    res.writeHead(200, { 
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache'
    });
    res.end(JSON.stringify({ 
      status: 'online', 
      timestamp: new Date().toISOString() 
    }));
    return;
  }
  
  // Ignorar favicon.ico para evitar erros no console
  if (req.url === '/favicon.ico') {
    res.writeHead(204); // No Content
    res.end();
    return;
  }
  
  // Rota não encontrada
  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Rota não encontrada');
});

const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Servidor rodando em:`);
  console.log(`   http://localhost:${PORT}`);
  console.log(`   http://127.0.0.1:${PORT}`);
  console.log('\nRotas disponíveis:');
  console.log('   GET /');
  console.log('   GET /api/status');
  console.log('\nPressione Ctrl+C para encerrar\n');
});
