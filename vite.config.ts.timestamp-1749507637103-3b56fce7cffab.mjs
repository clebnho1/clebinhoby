// vite.config.ts
import { defineConfig, loadEnv } from "file:///C:/Users/User/Desktop/ByClebinho/node_modules/vite/dist/node/index.js";
import react from "file:///C:/Users/User/Desktop/ByClebinho/node_modules/@vitejs/plugin-react/dist/index.mjs";
import path from "path";
import { fileURLToPath } from "url";
var __vite_injected_original_import_meta_url = "file:///C:/Users/User/Desktop/ByClebinho/vite.config.ts";
var __filename = fileURLToPath(__vite_injected_original_import_meta_url);
var __dirname = path.dirname(__filename);
var vite_config_default = defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  return {
    define: {
      "process.env": {
        ...env,
        NODE_ENV: process.env.NODE_ENV || "development"
      },
      // Define globalThis para compatibilidade com o Node.js
      global: "globalThis"
    },
    server: {
      host: "::",
      port: 3e3
    },
    plugins: [react()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
        // Adiciona suporte para process/browser
        "process": "process/browser",
        "process.env": "process-env"
      }
    },
    build: {
      outDir: "dist/client",
      emptyOutDir: true,
      rollupOptions: {
        input: {
          main: path.resolve(__dirname, "index.html")
        },
        output: {
          entryFileNames: "assets/[name].[hash].js",
          chunkFileNames: "assets/[name].[hash].js",
          assetFileNames: "assets/[name].[hash].[ext]"
        },
        // Garante que as variáveis de ambiente sejam substituídas corretamente
        define: {
          "process.env": {}
        }
      },
      // Habilita sourcemaps para facilitar o debug
      sourcemap: true
    },
    ssr: {
      target: "node",
      noExternal: true
    },
    // Configura o ambiente para o Vite
    mode: process.env.NODE_ENV || "development",
    // Configura o ambiente para o servidor de desenvolvimento
    envDir: process.cwd(),
    envPrefix: "VITE_"
  };
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFxVc2VyXFxcXERlc2t0b3BcXFxcQnlDbGViaW5ob1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiQzpcXFxcVXNlcnNcXFxcVXNlclxcXFxEZXNrdG9wXFxcXEJ5Q2xlYmluaG9cXFxcdml0ZS5jb25maWcudHNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL0M6L1VzZXJzL1VzZXIvRGVza3RvcC9CeUNsZWJpbmhvL3ZpdGUuY29uZmlnLnRzXCI7aW1wb3J0IHsgZGVmaW5lQ29uZmlnLCBsb2FkRW52IH0gZnJvbSAndml0ZSc7XG5pbXBvcnQgcmVhY3QgZnJvbSAnQHZpdGVqcy9wbHVnaW4tcmVhY3QnO1xuaW1wb3J0IHBhdGggZnJvbSAncGF0aCc7XG5pbXBvcnQgeyBmaWxlVVJMVG9QYXRoIH0gZnJvbSAndXJsJztcblxuY29uc3QgX19maWxlbmFtZSA9IGZpbGVVUkxUb1BhdGgoaW1wb3J0Lm1ldGEudXJsKTtcbmNvbnN0IF9fZGlybmFtZSA9IHBhdGguZGlybmFtZShfX2ZpbGVuYW1lKTtcblxuLy8gaHR0cHM6Ly92aXRlanMuZGV2L2NvbmZpZy9cbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZygoeyBtb2RlIH0pID0+IHtcbiAgLy8gQ2FycmVnYSBhcyB2YXJpXHUwMEUxdmVpcyBkZSBhbWJpZW50ZSBkbyBhcnF1aXZvIC5lbnZcbiAgY29uc3QgZW52ID0gbG9hZEVudihtb2RlLCBwcm9jZXNzLmN3ZCgpLCAnJyk7XG4gIFxuICByZXR1cm4ge1xuICAgIGRlZmluZToge1xuICAgICAgJ3Byb2Nlc3MuZW52Jzoge1xuICAgICAgICAuLi5lbnYsXG4gICAgICAgIE5PREVfRU5WOiBwcm9jZXNzLmVudi5OT0RFX0VOViB8fCAnZGV2ZWxvcG1lbnQnLFxuICAgICAgfSxcbiAgICAgIC8vIERlZmluZSBnbG9iYWxUaGlzIHBhcmEgY29tcGF0aWJpbGlkYWRlIGNvbSBvIE5vZGUuanNcbiAgICAgIGdsb2JhbDogJ2dsb2JhbFRoaXMnLFxuICAgIH0sXG4gICAgc2VydmVyOiB7XG4gICAgICBob3N0OiAnOjonLFxuICAgICAgcG9ydDogMzAwMCxcbiAgICB9LFxuICAgIHBsdWdpbnM6IFtyZWFjdCgpXSxcbiAgICByZXNvbHZlOiB7XG4gICAgICBhbGlhczoge1xuICAgICAgICAnQCc6IHBhdGgucmVzb2x2ZShfX2Rpcm5hbWUsICcuL3NyYycpLFxuICAgICAgICAvLyBBZGljaW9uYSBzdXBvcnRlIHBhcmEgcHJvY2Vzcy9icm93c2VyXG4gICAgICAgICdwcm9jZXNzJzogJ3Byb2Nlc3MvYnJvd3NlcicsXG4gICAgICAgICdwcm9jZXNzLmVudic6ICdwcm9jZXNzLWVudicsXG4gICAgICB9XG4gICAgfSxcbiAgICBidWlsZDoge1xuICAgICAgb3V0RGlyOiAnZGlzdC9jbGllbnQnLFxuICAgICAgZW1wdHlPdXREaXI6IHRydWUsXG4gICAgICByb2xsdXBPcHRpb25zOiB7XG4gICAgICAgIGlucHV0OiB7XG4gICAgICAgICAgbWFpbjogcGF0aC5yZXNvbHZlKF9fZGlybmFtZSwgJ2luZGV4Lmh0bWwnKVxuICAgICAgICB9LFxuICAgICAgICBvdXRwdXQ6IHtcbiAgICAgICAgICBlbnRyeUZpbGVOYW1lczogJ2Fzc2V0cy9bbmFtZV0uW2hhc2hdLmpzJyxcbiAgICAgICAgICBjaHVua0ZpbGVOYW1lczogJ2Fzc2V0cy9bbmFtZV0uW2hhc2hdLmpzJyxcbiAgICAgICAgICBhc3NldEZpbGVOYW1lczogJ2Fzc2V0cy9bbmFtZV0uW2hhc2hdLltleHRdJyxcbiAgICAgICAgfSxcbiAgICAgICAgLy8gR2FyYW50ZSBxdWUgYXMgdmFyaVx1MDBFMXZlaXMgZGUgYW1iaWVudGUgc2VqYW0gc3Vic3RpdHVcdTAwRURkYXMgY29ycmV0YW1lbnRlXG4gICAgICAgIGRlZmluZToge1xuICAgICAgICAgICdwcm9jZXNzLmVudic6IHt9XG4gICAgICAgIH1cbiAgICAgIH0sXG4gICAgICAvLyBIYWJpbGl0YSBzb3VyY2VtYXBzIHBhcmEgZmFjaWxpdGFyIG8gZGVidWdcbiAgICAgIHNvdXJjZW1hcDogdHJ1ZSxcbiAgICB9LFxuICAgIHNzcjoge1xuICAgICAgdGFyZ2V0OiAnbm9kZScsXG4gICAgICBub0V4dGVybmFsOiB0cnVlXG4gICAgfSxcbiAgICAvLyBDb25maWd1cmEgbyBhbWJpZW50ZSBwYXJhIG8gVml0ZVxuICAgIG1vZGU6IHByb2Nlc3MuZW52Lk5PREVfRU5WIHx8ICdkZXZlbG9wbWVudCcsXG4gICAgLy8gQ29uZmlndXJhIG8gYW1iaWVudGUgcGFyYSBvIHNlcnZpZG9yIGRlIGRlc2Vudm9sdmltZW50b1xuICAgIGVudkRpcjogcHJvY2Vzcy5jd2QoKSxcbiAgICBlbnZQcmVmaXg6ICdWSVRFXycsXG4gIH07XG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBNFIsU0FBUyxjQUFjLGVBQWU7QUFDbFUsT0FBTyxXQUFXO0FBQ2xCLE9BQU8sVUFBVTtBQUNqQixTQUFTLHFCQUFxQjtBQUhtSixJQUFNLDJDQUEyQztBQUtsTyxJQUFNLGFBQWEsY0FBYyx3Q0FBZTtBQUNoRCxJQUFNLFlBQVksS0FBSyxRQUFRLFVBQVU7QUFHekMsSUFBTyxzQkFBUSxhQUFhLENBQUMsRUFBRSxLQUFLLE1BQU07QUFFeEMsUUFBTSxNQUFNLFFBQVEsTUFBTSxRQUFRLElBQUksR0FBRyxFQUFFO0FBRTNDLFNBQU87QUFBQSxJQUNMLFFBQVE7QUFBQSxNQUNOLGVBQWU7QUFBQSxRQUNiLEdBQUc7QUFBQSxRQUNILFVBQVUsUUFBUSxJQUFJLFlBQVk7QUFBQSxNQUNwQztBQUFBO0FBQUEsTUFFQSxRQUFRO0FBQUEsSUFDVjtBQUFBLElBQ0EsUUFBUTtBQUFBLE1BQ04sTUFBTTtBQUFBLE1BQ04sTUFBTTtBQUFBLElBQ1I7QUFBQSxJQUNBLFNBQVMsQ0FBQyxNQUFNLENBQUM7QUFBQSxJQUNqQixTQUFTO0FBQUEsTUFDUCxPQUFPO0FBQUEsUUFDTCxLQUFLLEtBQUssUUFBUSxXQUFXLE9BQU87QUFBQTtBQUFBLFFBRXBDLFdBQVc7QUFBQSxRQUNYLGVBQWU7QUFBQSxNQUNqQjtBQUFBLElBQ0Y7QUFBQSxJQUNBLE9BQU87QUFBQSxNQUNMLFFBQVE7QUFBQSxNQUNSLGFBQWE7QUFBQSxNQUNiLGVBQWU7QUFBQSxRQUNiLE9BQU87QUFBQSxVQUNMLE1BQU0sS0FBSyxRQUFRLFdBQVcsWUFBWTtBQUFBLFFBQzVDO0FBQUEsUUFDQSxRQUFRO0FBQUEsVUFDTixnQkFBZ0I7QUFBQSxVQUNoQixnQkFBZ0I7QUFBQSxVQUNoQixnQkFBZ0I7QUFBQSxRQUNsQjtBQUFBO0FBQUEsUUFFQSxRQUFRO0FBQUEsVUFDTixlQUFlLENBQUM7QUFBQSxRQUNsQjtBQUFBLE1BQ0Y7QUFBQTtBQUFBLE1BRUEsV0FBVztBQUFBLElBQ2I7QUFBQSxJQUNBLEtBQUs7QUFBQSxNQUNILFFBQVE7QUFBQSxNQUNSLFlBQVk7QUFBQSxJQUNkO0FBQUE7QUFBQSxJQUVBLE1BQU0sUUFBUSxJQUFJLFlBQVk7QUFBQTtBQUFBLElBRTlCLFFBQVEsUUFBUSxJQUFJO0FBQUEsSUFDcEIsV0FBVztBQUFBLEVBQ2I7QUFDRixDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
