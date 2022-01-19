const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  purge: {
    content: ["src/website/src/**/*.html", "src/website/src/**/*.vue"],
    enabled: true,
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        marker: ["Permanent Marker", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        pink: {
          DEFAULT: "#d51d81",
        },
      },
    },
  },
  variants: {
    animation: ["responsive", "motion-safe", "motion-reduce"],
  },
  plugins: [],
};
