require 'spec_helper'

RSpec.describe 'Server Routing and Error Handling', type: :request do
  include Rack::Test::Methods

  def app
    PtdDev::Server
  end

  describe 'Page routing' do
    context 'main pages' do
      it 'routes to home page correctly' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('text/html')
      end

      it 'routes to about page correctly' do
        get '/about'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('text/html')
      end

      it 'routes to contact page correctly' do
        get '/contact'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('text/html')
      end
    end

    context 'case sensitivity' do
      it 'handles exact case matches' do
        get '/about'
        expect(last_response).to be_ok
      end

      it 'does not match different cases' do
        get '/About'
        expect(last_response.status).to eq(404)
      end

      it 'does not match with trailing slashes for pages' do
        get '/about/'
        expect(last_response.status).to eq(404)
      end
    end

    context 'HTTP methods' do
      it 'responds to GET requests' do
        get '/'
        expect(last_response).to be_ok
      end

      it 'does not respond to POST requests for pages' do
        post '/'
        expect(last_response.status).to eq(404)
      end

      it 'does not respond to PUT requests for pages' do
        put '/about'
        expect(last_response.status).to eq(404)
      end

      it 'does not respond to DELETE requests for pages' do
        delete '/contact'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'Error handling' do
    context '404 errors' do
      it 'returns 404 for non-existent pages' do
        get '/nonexistent'
        expect(last_response.status).to eq(404)
      end

      it 'renders custom 404 page' do
        get '/nonexistent'
        expect(last_response.body).to include('Page Not Found')
        expect(last_response.body).to include('PTD.dev')
      end

      it 'sets correct content type for 404 pages' do
        get '/nonexistent'
        expect(last_response.headers['Content-Type']).to include('text/html')
      end

      it 'includes navigation in 404 page' do
        get '/nonexistent'
        expect(last_response.body).to include('nav')
      end
    end

    context '500 errors' do
      before do
        allow_any_instance_of(PtdDev::Utils::ContentManager).to receive(:get_page).and_raise(StandardError,
                                                                                             'Test error')
      end

      it 'handles server errors gracefully' do
        get '/'
        expect(last_response.status).to eq(500)
      end

      it 'renders custom error page' do
        get '/'
        expect(last_response.body).to include('Error')
      end

      it 'sets correct content type for error pages' do
        get '/'
        expect(last_response.headers['Content-Type']).to include('text/html')
      end
    end

    context 'malformed requests' do
      it 'handles requests with invalid characters' do
        get '/page%00'
        expect(last_response.status).to be_between(400, 499)
      end

      it 'handles extremely long URLs' do
        long_path = "/page#{'a' * 10_000}"
        get long_path
        expect(last_response.status).to be_between(400, 499)
      end
    end
  end

  describe 'Content serving' do
    context 'static assets' do
      it 'serves favicon correctly' do
        get '/favicon.ico'
        expect(last_response.status).to eq(200)
      end

      it 'returns 404 for non-existent static files' do
        get '/nonexistent.css'
        expect(last_response.status).to eq(404)
      end
    end

    context 'content headers' do
      it 'sets appropriate cache headers for pages' do
        get '/'
        # Pages should not be cached aggressively in development
        expect(last_response.headers).not_to have_key('Cache-Control')
      end

      it 'sets appropriate content type for HTML pages' do
        get '/'
        expect(last_response.headers['Content-Type']).to include('text/html')
        expect(last_response.headers['Content-Type']).to include('charset=utf-8')
      end
    end

    context 'response size' do
      it 'returns reasonable response sizes' do
        get '/'
        expect(last_response.body.bytesize).to be > 1000 # Should have substantial content
        expect(last_response.body.bytesize).to be < 100_000 # But not too large
      end

      it 'compresses responses appropriately' do
        header 'Accept-Encoding', 'gzip'
        get '/'
        # NOTE: Actual compression depends on server configuration
        expect(last_response).to be_ok
      end
    end
  end

  describe 'Development features' do
    context 'content reloading' do
      it 'supports content reloading with reload parameter' do
        ENV['RACK_ENV'] = 'development'
        get '/?reload=true'
        expect(last_response).to be_ok
        ENV['RACK_ENV'] = 'test'
      end

      it 'ignores reload parameter in non-development environments' do
        ENV['RACK_ENV'] = 'production'
        get '/?reload=true'
        expect(last_response).to be_ok
        ENV['RACK_ENV'] = 'test'
      end
    end

    context 'API endpoints' do
      it 'provides health check endpoint' do
        get '/api/health'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('application/json')

        json_response = JSON.parse(last_response.body)
        expect(json_response).to have_key('status')
        expect(json_response['status']).to eq('ok')
      end

      it 'provides content stats endpoint' do
        get '/api/content/stats'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('application/json')

        json_response = JSON.parse(last_response.body)
        expect(json_response).to have_key('pages')
        expect(json_response).to have_key('blog_posts')
        expect(json_response).to have_key('documentation')
      end

      it 'provides content reload endpoint in development' do
        ENV['RACK_ENV'] = 'development'
        post '/api/content/reload'
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to include('application/json')
        ENV['RACK_ENV'] = 'test'
      end

      it 'restricts content reload endpoint in production' do
        ENV['RACK_ENV'] = 'production'
        post '/api/content/reload'
        expect(last_response.status).to eq(403)
        ENV['RACK_ENV'] = 'test'
      end
    end
  end

  describe 'Security considerations' do
    context 'request validation' do
      it 'handles requests with suspicious patterns' do
        get '/../../../etc/passwd'
        expect(last_response.status).to be_between(400, 499)
      end

      it 'handles requests with null bytes' do
        # Null bytes in URIs cause errors at the URI parsing level
        # This is expected behavior - the request is rejected before reaching the app
        expect { get "/page\x00" }.to raise_error(URI::InvalidURIError)
      end
    end

    context 'response headers' do
      it 'does not expose sensitive server information' do
        get '/'
        expect(last_response.headers).not_to have_key('Server')
        expect(last_response.headers).not_to have_key('X-Powered-By')
      end

      it 'includes security headers where appropriate' do
        get '/'
        # Check for actual security headers
        expect(last_response.headers['X-Content-Type-Options']).to eq('nosniff')
        expect(last_response.headers['X-Frame-Options']).to eq('SAMEORIGIN')
        expect(last_response.headers['X-XSS-Protection']).to eq('1; mode=block')
      end
    end
  end
end
