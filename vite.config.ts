import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  // Carrega as variáveis de ambiente do arquivo .env
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    define: {
      'process.env': {
        ...env,
        NODE_ENV: process.env.NODE_ENV || 'development',
      },
      // Define globalThis para compatibilidade com o Node.js
      global: 'globalThis',
    },
    server: {
      host: '0.0.0.0',
      port: 8081,
      strictPort: true,
      open: true,
      hmr: {
        port: 8081,
        protocol: 'ws',
        host: 'localhost',
        overlay: true
      },
      cors: true,
      fs: {
        strict: true,
      }
    },
    plugins: [
      react({
        jsxImportSource: '@emotion/react',
        babel: {
          plugins: ['@emotion/babel-plugin'],
        },
      })
    ],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        // Adiciona suporte para process/browser
        'process': 'process/browser',
        'process.env': 'process-env',
      }
    },
    build: {
      outDir: 'dist',
      emptyOutDir: true,
      sourcemap: true,
      minify: 'terser',
      rollupOptions: {
        input: {
          main: path.resolve(__dirname, 'index.html')
        },
        output: {
          entryFileNames: 'assets/[name].[hash].js',
          chunkFileNames: 'assets/[name].[hash].js',
          assetFileNames: 'assets/[name].[hash].[ext]',
        },
        // Garante que as variáveis de ambiente sejam substituídas corretamente
        define: {
          'process.env': {}
        }
      },
    },
    ssr: {
      target: 'node',
      noExternal: true
    },
    // Configura o ambiente para o Vite
    mode: process.env.NODE_ENV || 'development',
    // Configura o ambiente para o servidor de desenvolvimento
    envDir: process.cwd(),
    envPrefix: 'VITE_',
  };
});
