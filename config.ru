require_relative 'src/server'

# Configure Rack middleware
use Rack::Static, urls: ['/css', '/js', '/images', '/favicon.ico'], root: 'public'
use Rack::CommonLogger
use Rack::ShowExceptions if ENV['RACK_ENV'] == 'development'

# Run the PTD server application
run PtdDev::Server
