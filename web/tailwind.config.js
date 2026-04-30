/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        primary: "hsl(210, 55%, 55%)",
        secondary: "hsl(340, 45%, 60%)",
        backgroundDark: "hsl(210, 10%, 12%)",
        backgroundLight: "hsl(0, 0%, 98%)",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"]
      },
      boxShadow: {
        glass: "0 4px 12px rgba(0,0,0,0.15)"
      },
      borderRadius: {
        DEFAULT: "0.75rem"
      }
    }
  },
  plugins: []
};
