import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: '127.0.0.1', // Force IPv4 to avoid IPv6 issues
    strictPort: false, // Will try next port if 3000 is taken
  },
  build: {
    outDir: "build", // Or your desired output directory
  },
});
