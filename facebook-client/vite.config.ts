import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173, // Порт, на якому буде працювати фронтенд
    host: '0.0.0.0' // Дозволяє доступ з зовнішніх IP-адрес
  }
})
