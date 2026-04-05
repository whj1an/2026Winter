/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./pages/**/*.{js,jsx}', './components/**/*.{js,jsx}'],
  theme: {
    extend: {
      fontFamily: {
        display: ['Georgia', 'Cambria', 'serif'],
        body: ['Garamond', 'Georgia', 'serif'],
        mono: ['Courier New', 'monospace'],
      },
      colors: {
        cream: '#FAF7F2',
        gold: '#C9A84C',
        'gold-light': '#E8C97A',
        'gold-dark': '#9B7A2F',
        charcoal: '#1C1C1E',
        'charcoal-soft': '#2C2C2E',
        mist: '#F0EDE8',
        stone: '#8A8480',
        'stone-light': '#C5BFB8',
        ruby: '#8B1A1A',
      },
      boxShadow: {
        'luxury': '0 4px 40px rgba(0,0,0,0.12)',
        'card': '0 2px 20px rgba(0,0,0,0.08)',
        'gold': '0 2px 20px rgba(201,168,76,0.25)',
      },
    },
  },
  plugins: [],
}
