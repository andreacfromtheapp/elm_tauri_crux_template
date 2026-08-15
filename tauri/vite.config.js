import process from "node:process";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

const host = process.env.TAURI_DEV_HOST;

import viteCompression from "vite-plugin-compression";
import elmPluginWatch from "vite-plugin-elm-watch";
import viteImagemin from "vite-plugin-imagemin";
import { ViteWebfontDownload } from "vite-plugin-webfont-dl";

// Vite options tailored for Tauri development and only applied in `tauri dev` or `tauri build`
// https://vite.dev/config/
export default defineConfig(() => ({
  // prevent vite from obscuring rust errors
  clearScreen: false,
  server: {
    // make sure this port matches the devUrl port in tauri.conf.json file
    port: 5173,
    // Tauri expects a fixed port, fail if that port is not available
    strictPort: true,
    // if the host Tauri is expecting is set, use it
    host: host || false,
    hmr: host
      ? {
          protocol: "ws",
          host,
          port: 1421,
        }
      : undefined,

    watch: {
      // tell vite to ignore watching `src-tauri`
      ignored: ["**/src-tauri/**", "README.md"],
    },
  },

  // Env variables starting with the item of `envPrefix` will be exposed in tauri's source code through `import.meta.env`.
  envPrefix: ["VITE_", "TAURI_ENV_*"],
  build: {
    // Tauri uses Chromium on Windows and WebKit on macOS and Linux
    target:
      process.env.TAURI_ENV_PLATFORM === "windows" ? "chrome105" : "safari13",
    // don't minify for debug builds
    minify: !process.env.TAURI_ENV_DEBUG ? "esbuild" : false,
    // produce sourcemaps for debug builds
    sourcemap: !!process.env.TAURI_ENV_DEBUG,
  },

  plugins: [
    elmPluginWatch(),
    tailwindcss(),
    ViteWebfontDownload(),
    viteImagemin({
      gifsicle: {
        optimizationLevel: 3,
        interlaced: false,
      },
      optipng: {
        optimizationLevel: 7,
      },
      mozjpeg: {
        quality: 80,
        progressive: true,
      },
      pngquant: {
        quality: [0.8, 0.9],
        speed: 10,
      },
      svgo: {
        plugins: ["preset-default"],
      },
      webp: {
        quality: 80,
        method: 4,
        nearLossless: 95,
      },
    }),
    viteCompression({
      algorithm: "brotliCompress",
    }),
  ],
}));
