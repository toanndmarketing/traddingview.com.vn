module.exports = {
  apps: [
    {
      name: 'ghost-tradingview',
      script: 'versions/5.58.0/index.js',
      cwd: '/var/www/tradingview.com.vn',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production'
      },
      error_file: './content/logs/pm2-error.log',
      out_file: './content/logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000
    }
  ]
};

