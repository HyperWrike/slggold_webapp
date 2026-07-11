// Ambient type declarations for CSS imports handled by the Expo/Metro bundler.
// These let `tsc --noEmit` succeed for side-effect and CSS-module imports.

declare module "*.css";

declare module "*.module.css" {
  const classes: { readonly [key: string]: string };
  export default classes;
}
