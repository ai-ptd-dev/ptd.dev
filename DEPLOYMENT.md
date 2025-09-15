# Deployment Guide for PTD.dev

This guide covers deploying the PTD.dev Sinatra application to various platforms.

## Local Development

```bash
# Install dependencies
bundle install

# Start development server
./bin/server

# Start with auto-reload
./bin/server --rerun

# Run tests
./bin/rspec
```

## Production Deployment

### Environment Variables

Set these environment variables for production:

```bash
export RACK_ENV=production
export SINATRA_ENV=production
export PORT=4567  # or your preferred port
```

### Using Puma (Recommended)

Create `config/puma.rb`:

```ruby
# config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 4567
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
end
```

Start with:
```bash
bundle exec puma -C config/puma.rb
```

### Docker Deployment

```dockerfile
FROM ruby:3.1-alpine

# Install dependencies
RUN apk add --no-cache build-base

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy application code
COPY . .

# Expose port
EXPOSE 4567

# Start the application
CMD ["bundle", "exec", "rackup", "-p", "4567", "-o", "0.0.0.0"]
```

Build and run:
```bash
docker build -t ptd-dev .
docker run -p 4567:4567 ptd-dev
```

### Heroku Deployment

1. Create a `Procfile`:
```
web: bundle exec rackup -p $PORT
```

2. Deploy:
```bash
heroku create your-app-name
git push heroku main
```

### Nginx Reverse Proxy

```nginx
server {
    listen 80;
    server_name ptd.dev www.ptd.dev;

    location / {
        proxy_pass http://127.0.0.1:4567;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Serve static files directly
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        root /path/to/ptd.dev/public;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## Performance Optimization

### Content Caching

The application loads all content into memory on startup. For production:

1. **Restart after content changes**: The content manager loads files on startup
2. **Monitor memory usage**: Large content collections may require optimization
3. **Consider Redis caching**: For high-traffic sites

### Static Asset Serving

For production, serve static assets through a CDN or web server:

```ruby
# In production, disable Sinatra's static file serving
configure :production do
  set :static, false
end
```

### Database Considerations

Currently, the application uses file-based content. For dynamic content:

1. **Add database support**: PostgreSQL, MySQL, or SQLite
2. **Implement caching**: Redis or Memcached
3. **Content versioning**: Git-based content management

## Monitoring

### Health Checks

The application provides health check endpoints:

- `GET /api/health` - Basic health status
- `GET /api/content/stats` - Content statistics

### Logging

Configure logging for production:

```ruby
configure :production do
  enable :logging
  set :logger, Logger.new(STDOUT)
end
```

### Error Tracking

Consider integrating error tracking services:

- Sentry
- Bugsnag
- Rollbar

## Security

### HTTPS

Always use HTTPS in production:

```ruby
configure :production do
  use Rack::SSL
end
```

### Content Security Policy

Add CSP headers:

```ruby
before do
  headers 'Content-Security-Policy' => "default-src 'self'; script-src 'self' 'unsafe-inline' cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' cdn.jsdelivr.net"
end
```

## Backup and Recovery

### Content Backup

Since content is file-based:

1. **Version control**: Keep content in Git
2. **Regular backups**: Backup the entire repository
3. **Automated deployment**: Use CI/CD for content updates

### Application Backup

1. **Code repository**: Ensure code is in version control
2. **Dependencies**: Lock gem versions in Gemfile.lock
3. **Configuration**: Document environment variables

## Scaling

### Horizontal Scaling

The application is stateless and can be scaled horizontally:

1. **Load balancer**: Distribute traffic across instances
2. **Session storage**: Use Redis for session data if needed
3. **Content synchronization**: Ensure all instances have same content

### Vertical Scaling

For single-instance deployments:

1. **Memory**: Monitor content loading memory usage
2. **CPU**: Profile request handling performance
3. **Storage**: Monitor log file growth

## Troubleshooting

### Common Issues

1. **Content not loading**: Check file permissions and paths
2. **Markdown not rendering**: Verify Rouge and Redcarpet installation
3. **Static assets 404**: Check public folder configuration

### Debug Mode

Enable debug mode for troubleshooting:

```bash
export RACK_ENV=development
export SINATRA_ENV=development
```

### Log Analysis

Monitor application logs for:

- Request patterns
- Error frequencies
- Performance bottlenecks
- Content access patterns