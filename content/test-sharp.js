const sharp = require('/var/lib/ghost/versions/5.58.0/node_modules/sharp');
console.log('Sharp version:', sharp.versions);
console.log('Sharp formats:', JSON.stringify(sharp.format, null, 2));
