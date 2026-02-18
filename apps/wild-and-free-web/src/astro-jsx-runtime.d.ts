declare module 'astro/jsx-runtime' {
  import '../node_modules/astro/astro-jsx.js';
  export * from '../node_modules/astro/dist/jsx-runtime/index.js';
  export import JSX = astroHTML.JSX;
}

declare module 'lottie-web';
