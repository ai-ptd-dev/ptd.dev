require 'spec_helper'
require 'rack/test'

RSpec.describe PtdDev::Server do
  include Rack::Test::Methods

  def app
    PtdDev::Server
  end

  describe 'GET /' do
    it 'returns successful response' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('PTD.dev')
    end

    it 'includes hero section' do
      get '/'
      expect(last_response.body).to include('Write Expressive')
      expect(last_response.body).to include('Deploy Native')
    end
  end

  describe 'GET /about' do
    it 'returns successful response' do
      get '/about'
      expect(last_response).to be_ok
      expect(last_response.body).to include('About PTD')
    end
  end

  describe 'GET /contact' do
    it 'returns successful response' do
      get '/contact'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Contact')
    end
  end

  describe 'GET /docs' do
    it 'returns successful response' do
      get '/docs'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Documentation')
    end
  end

  describe 'GET /blog' do
    it 'returns successful response' do
      get '/blog'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Blog')
    end
  end

  describe 'GET /api/health' do
    it 'returns health status as JSON' do
      get '/api/health'
      expect(last_response).to be_ok
      expect(last_response.content_type).to include('application/json')

      json = JSON.parse(last_response.body)
      expect(json['status']).to eq('ok')
      expect(json).to have_key('timestamp')
    end
  end

  describe 'GET /api/content/stats' do
    it 'returns content statistics as JSON' do
      get '/api/content/stats'
      expect(last_response).to be_ok
      expect(last_response.content_type).to include('application/json')

      json = JSON.parse(last_response.body)
      expect(json).to have_key('pages')
      expect(json).to have_key('blog_posts')
      expect(json).to have_key('documentation')
    end
  end

  describe 'GET /nonexistent' do
    it 'returns 404 for non-existent pages' do
      get '/nonexistent'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include('Page Not Found')
    end
  end
end
