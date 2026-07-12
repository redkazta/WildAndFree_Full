/** @type {import('tailwindcss').Config} */
export default {
  important: true,
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        wild: {
          orange: 'var(--wild-orange)',
          red: 'var(--wild-red)',
        },
        tenant: {
          primary: 'var(--tenant-primary)',
          secondary: 'var(--tenant-secondary)',
        },
      },
      fontFamily: {
        display: ['"Bebas Neue"', 'sans-serif'],
        body: ['Outfit', 'sans-serif'],
        mono: ['"Space Mono"', 'monospace'],
      },
      fontSize: {
        'display-xl': ['clamp(4rem, 12vw, 9rem)', { lineHeight: '0.9', letterSpacing: '-0.04em', fontWeight: '900' }],
        'display-lg': ['clamp(3rem, 8vw, 6rem)', { lineHeight: '0.95', letterSpacing: '-0.03em', fontWeight: '900' }],
        'display-md': ['clamp(2rem, 5vw, 3.5rem)', { lineHeight: '1', letterSpacing: '-0.02em', fontWeight: '800' }],
        'label': ['0.625rem', { lineHeight: '1', letterSpacing: '0.15em', fontWeight: '900' }],
        'label-sm': ['0.75rem', { lineHeight: '1', letterSpacing: '0.15em', fontWeight: '900' }],
      },
      spacing: {
        'section': '6rem',
        'section-lg': '8rem',
        'section-xl': '12rem',
      },
      borderRadius: {
        'wild': '1rem',
        'wild-lg': '1.5rem',
        'wild-xl': '2rem',
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.6s ease-out forwards',
        'fade-in': 'fadeIn 0.4s ease-out forwards',
        'pulse-glow': 'pulseGlow 2s ease-in-out infinite',
        'equalizer-1': 'equalizer 0.8s ease-in-out infinite',
        'equalizer-2': 'equalizer 1s ease-in-out infinite 0.1s',
        'equalizer-3': 'equalizer 1.2s ease-in-out infinite 0.2s',
        'equalizer-4': 'equalizer 0.9s ease-in-out infinite 0.3s',
        'equalizer-5': 'equalizer 1.1s ease-in-out infinite 0.15s',
        'gradient-shift': 'gradientShift 8s linear infinite',
        'scroll-down': 'scrollDown 2s ease-in-out infinite',
      },
      keyframes: {
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        pulseGlow: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(201, 131, 0, 0.2)' },
          '50%': { boxShadow: '0 0 40px rgba(201, 131, 0, 0.5)' },
        },
        equalizer: {
          '0%, 100%': { height: '20%' },
          '50%': { height: '100%' },
        },
        gradientShift: {
          '0%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
          '100%': { backgroundPosition: '0% 50%' },
        },
        scrollDown: {
          '0%': { transform: 'translateY(-20px)', opacity: '0' },
          '50%': { opacity: '1' },
          '100%': { transform: 'translateY(20px)', opacity: '0' },
        },
      },
      boxShadow: {
        'wild-glow': '0 0 50px rgba(201, 131, 0, 0.1)',
        'wild-glow-lg': '0 10px 40px rgba(201, 131, 0, 0.15)',
        'tenant-glow': '0 0 50px var(--tenant-glow)',
      },
      maxWidth: {
        'content': '1200px',
        'wide': '1600px',
        'prose': '65ch',
      },
      transitionDuration: {
        'wild': '300ms',
        'wild-slow': '500ms',
        'wild-slower': '700ms',
      },
      transitionTimingFunction: {
        'wild': 'cubic-bezier(0.23, 1, 0.32, 1)',
      },
    },
  },
  plugins: [],
}