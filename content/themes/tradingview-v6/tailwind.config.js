/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './*.hbs',
    './partials/**/*.hbs',
  ],
  safelist: [
    // Generate ALL common utility classes với pattern matching
    {
      pattern: /^(bg|text|border|ring)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-(50|100|200|300|400|500|600|700|800|900|950)$/,
    },
    {
      pattern: /^(p|m|px|py|pt|pb|pl|pr|mx|my|mt|mb|ml|mr)-(0|0\.5|1|1\.5|2|2\.5|3|3\.5|4|5|6|7|8|9|10|11|12|14|16|20|24|28|32|36|40|44|48|52|56|60|64|72|80|96)$/,
    },
    {
      pattern: /^(w|h|min-w|min-h|max-w|max-h)-(0|px|0\.5|1|1\.5|2|2\.5|3|3\.5|4|5|6|7|8|9|10|11|12|14|16|20|24|28|32|36|40|44|48|52|56|60|64|72|80|96|auto|full|screen|min|max|fit)$/,
    },
    {
      pattern: /^text-(xs|sm|base|lg|xl|2xl|3xl|4xl|5xl|6xl|7xl|8xl|9xl)$/,
    },
    {
      pattern: /^font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)$/,
    },
    {
      pattern: /^rounded(-none|-sm|-md|-lg|-xl|-2xl|-3xl|-full)?$/,
    },
    {
      pattern: /^(flex|inline-flex|grid|inline-grid|block|inline-block|inline|hidden)$/,
    },
    {
      pattern: /^(relative|absolute|fixed|sticky|static)$/,
    },
    {
      pattern: /^(top|right|bottom|left|inset)-(0|px|0\.5|1|1\.5|2|2\.5|3|3\.5|4|5|6|8|10|12|16|20|24|auto)$/,
    },
    {
      pattern: /^(opacity|shadow|ring|border)-.+$/,
    },
    {
      pattern: /^animate-.+$/,
    },
    // Specific classes thường dùng
    'container', 'space-x-2', 'space-y-2', 'divide-x', 'divide-y',
    'transition', 'duration-300', 'ease-in-out', 'transform',
    'cursor-pointer', 'pointer-events-none', 'select-none',
    'overflow-hidden', 'overflow-auto', 'overflow-scroll',
    'z-0', 'z-10', 'z-20', 'z-30', 'z-40', 'z-50',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
