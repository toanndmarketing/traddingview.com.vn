/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './*.hbs',
    './partials/**/*.hbs',
  ],
  safelist: [
    // Animation classes
    'animate-ping',
    // Positioning & Layout
    'flex', 'relative', 'absolute', 'inline-flex',
    // Spacing
    'px-3', 'py-2', 'top-0', 'top-1.5', 'right-0', 'right-20', '-mt-1', '-mr-1',
    // Sizing
    'h-2', 'h-full', 'w-2', 'w-full',
    // Colors
    'bg-blue-700', 'bg-yellow-500', 'bg-yellow-800',
    'text-white', 'text-xs',
    // Effects
    'rounded-lg', 'rounded-full', 'opacity-75',
    // Typography
    'font-medium', 'text-center',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
