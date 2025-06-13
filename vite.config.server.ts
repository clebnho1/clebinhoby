import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig({
  plugins: [react()],
  server: {
    port: 8081,
    strictPort: true,
    host: true,
    origin: 'http://localhost:8081',
    hmr: {
      protocol: 'ws',
      host: 'localhost',
      port: 8081
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
  define: {
    'process.env': {}
  }
});
