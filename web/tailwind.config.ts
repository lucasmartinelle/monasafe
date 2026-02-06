import type { Config } from 'tailwindcss'

export default {
  content: [
    './components/**/*.{vue,js,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './composables/**/*.{js,ts}',
    './plugins/**/*.{js,ts}',
    './app.vue',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1B5E5A',
          light: '#4A8B87',
          dark: '#0D3D3A',
        },
        accent: {
          DEFAULT: '#E87B4D',
          light: '#F5A882',
          dark: '#C45A2E',
        },
        surface: {
          light: '#FFFFFF',
          dark: '#1E1E1E',
        },
        background: {
          light: '#E8E8E8',
          dark: '#121212',
        },
        card: {
          light: '#FFFFFF',
          dark: '#2C2C2C',
        },
        success: '#4CAF50',
        warning: '#FF9800',
        error: '#F44336',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        heading: ['Poppins', 'sans-serif'],
      },
      borderRadius: {
        DEFAULT: '12px',
        lg: '16px',
        xl: '20px',
      },
    },
  },
  plugins: [],
} satisfies Config
