require 'spec_helper'

RSpec.describe 'Server Pages Integration', type: :request do
  include Rack::Test::Methods

  def app
    PtdDev::Server
  end

  describe 'Page routing and rendering' do
    context 'when accessing the home page' do
      it 'returns successful response' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
      end

      it 'renders the home page content' do
        get '/'
        expect(last_response.body).to include('PTD.dev')
        expect(last_response.body).to include('Write Expressive')
        expect(last_response.body).to include('Deploy Native')
      end

      it 'sets the correct page title' do
        get '/'
        expect(last_response.body).to include('<title>PTD.dev - Polyglot Transpilation Development</title>')
      end

      it 'includes navigation elements' do
        get '/'
        expect(last_response.body).to include('nav')
      end
    end

    context 'when accessing the about page' do
      it 'returns successful response' do
        get '/about'
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
      end

      it 'renders the about page content' do
        get '/about'
        expect(last_response.body).to include('About PTD')
        expect(last_response.body).to include('Polyglot Transpilation Development')
      end

      it 'sets the correct page title' do
        get '/about'
        expect(last_response.body).to include('<title>About PTD - Polyglot Transpilation Development</title>')
      end

      it 'includes the problem and solution sections' do
        get '/about'
        expect(last_response.body).to include('The Problem')
        expect(last_response.body).to include('The PTD Solution')
      end
    end

    context 'when accessing the contact page' do
      it 'returns successful response' do
        get '/contact'
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
      end

      it 'renders the contact page content' do
        get '/contact'
        expect(last_response.body).to include('Contact')
      end

      it 'sets the correct page title' do
        get '/contact'
        expect(last_response.body).to include('<title>Contact - PTD.dev</title>')
      end
    end
  end

  describe 'Page metadata handling' do
    let(:content_manager) { PtdDev::Utils::ContentManager.new }

    it 'extracts frontmatter from pages correctly' do
      home_page = content_manager.get_page('home')
      expect(home_page[:title]).to eq('PTD.dev - Polyglot Transpilation Development')
      expect(home_page[:description]).to include('AI-powered transpilation')
    end

    it 'handles pages without frontmatter gracefully' do
      # Test with a page that might not have frontmatter
      page = content_manager.get_page('contact')
      expect(page).to be_a(Hash)
      expect(page[:slug]).to eq('contact')
    end

    it 'includes file modification timestamps' do
      page = content_manager.get_page('home')
      expect(page[:updated_at]).to be_a(Time)
    end
  end

  describe 'Error handling for pages' do
    context 'when accessing a non-existent page' do
      it 'returns 404 status' do
        get '/nonexistent-page'
        expect(last_response.status).to eq(404)
      end

      it 'renders the not found template' do
        get '/nonexistent-page'
        expect(last_response.body).to include('Page Not Found')
      end

      it 'sets the correct error page title' do
        get '/nonexistent-page'
        expect(last_response.body).to include('<title>Page Not Found - PTD.dev</title>')
      end
    end

    context 'when there are server errors' do
      before do
        allow_any_instance_of(PtdDev::Utils::ContentManager).to receive(:get_page).and_raise(StandardError,
                                                                                             'Test error')
      end

      it 'handles errors gracefully' do
        get '/'
        expect(last_response.status).to eq(500)
      end

      it 'renders the error template' do
        get '/'
        expect(last_response.body).to include('Error')
      end
    end
  end

  describe 'Content serving workflow' do
    it 'serves static assets correctly' do
      get '/favicon.ico'
      expect(last_response.status).to eq(200)
    end

    it 'handles content reloading in development' do
      ENV['RACK_ENV'] = 'development'
      get '/?reload=true'
      expect(last_response).to be_ok
      ENV['RACK_ENV'] = 'test'
    end

    it 'includes proper HTML structure' do
      get '/'
      expect(last_response.body).to include('<!DOCTYPE html>')
      expect(last_response.body).to include('<html')
      expect(last_response.body).to include('<head>')
      expect(last_response.body).to include('<body>')
    end

    it 'includes responsive meta tags' do
      get '/'
      expect(last_response.body).to include('viewport')
      expect(last_response.body).to include('width=device-width')
    end
  end

  describe 'Page content processing' do
    it 'processes HTML content correctly' do
      get '/about'
      expect(last_response.body).to include('<div class="container')
      expect(last_response.body).to include('<h1>')
      expect(last_response.body).to include('<p class="lead">')
    end

    it 'preserves HTML structure from page files' do
      get '/about'
      expect(last_response.body).to include('<div class="row">')
      expect(last_response.body).to include('<div class="col-md-6">')
    end

    it 'includes Bootstrap CSS classes' do
      get '/'
      expect(last_response.body).to include('btn')
      expect(last_response.body).to include('container')
      expect(last_response.body).to include('row')
    end
  end

  describe 'Navigation and links' do
    it 'includes navigation links to all main pages' do
      get '/'
      expect(last_response.body).to include('href="/about"')
      expect(last_response.body).to include('href="/contact"')
      expect(last_response.body).to include('href="/docs"')
      expect(last_response.body).to include('href="/blog"')
    end

    it 'includes external links with proper attributes' do
      get '/about'
      expect(last_response.body).to include('target="_blank"')
      expect(last_response.body).to include('rel="noopener noreferrer"')
    end

    it 'includes call-to-action buttons' do
      get '/'
      expect(last_response.body).to include('Get Started')
      expect(last_response.body).to include('href="/docs"')
    end
  end
end
