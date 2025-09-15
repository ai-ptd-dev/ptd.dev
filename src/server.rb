#!/usr/bin/env ruby

# PTD Static Site Generator Server
# Serves the static site with dynamic content rendering

require 'sinatra/base'
require 'sinatra/reloader'
require 'erb'
require 'redcarpet'
require 'coderay'
require 'json'
require_relative 'utils/content_manager'
require_relative 'utils/markdown_renderer'

module PtdDev
  # Main server application for the PTD static site generator
  # Handles routing, content serving, and template rendering
  class Server < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    set :views, File.expand_path('../views', __dir__)
    set :public_folder, File.expand_path('../public', __dir__)

    # Configure ERB for proper HTML handling
    # Using standard ERB without automatic escaping
    # We'll escape manually where needed
    set :erb, {
      escape_html: false
    }

    # Initialize content manager and renderer
    configure do
      set :content_manager, Utils::ContentManager.new
      set :markdown_renderer, Utils::MarkdownRenderer.new

      # Enable content reloading in development
      if development?
        before do
          settings.content_manager.reload_content if params[:reload] == 'true'
        end
      end
    end

    # Set security headers and validate requests
    before do
      # Validate for null bytes in the request path
      halt 400, { 'Content-Type' => 'text/plain' }, 'Bad Request' if request.path_info.include?("\x00")

      # Disable caching in development
      if development?
        headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        headers['Pragma'] = 'no-cache'
        headers['Expires'] = '0'
      end

      headers['X-Content-Type-Options'] = 'nosniff'
      headers['X-Frame-Options'] = 'SAMEORIGIN'
      headers['X-XSS-Protection'] = '1; mode=block'
      headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
      headers['Permissions-Policy'] =
        'accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()'
    end

    # Routes
    get '/' do
      page = settings.content_manager.get_page('home')
      halt 404 unless page

      @page_title = page[:title]
      @page_description = page[:description] ||
                           'Write in expressive languages (Ruby, Python, JavaScript) and ' \
                           'deploy with native performance (Rust, Swift, C#) using AI-powered transpilation.'
      @content = page[:content]
      erb :page
    end

    get '/about' do
      page = settings.content_manager.get_page('about')
      halt 404 unless page

      @page_title = page[:title]
      @page_description = page[:description] ||
                           'Learn about Polyglot Transpilation Development and how AI enables ' \
                           'native performance without sacrificing developer productivity.'
      @content = page[:content]
      erb :page
    end

    get '/contact' do
      page = settings.content_manager.get_page('contact')
      halt 404 unless page

      @page_title = page[:title]
      @page_description = page[:description] ||
                           'Get in touch with the PTD team and join the community of ' \
                           'developers using AI-powered transpilation.'
      @content = page[:content]
      erb :page
    end

    get '/docs' do
      @page_title = 'Documentation - PTD.dev'
      @page_description = 'Learn how to use PTD to transpile Ruby, Python, and JavaScript to ' \
                           'native Rust, Swift, and C# code.'
      @docs = settings.content_manager.get_documentation_index
      erb :docs_index
    end

    get '/docs/:category/:slug' do
      category = params[:category]
      slug = params[:slug]

      @doc = settings.content_manager.get_documentation(category, slug)
      halt 404 unless @doc

      @page_title = "#{@doc[:title]} - PTD.dev Documentation"
      @page_description = @doc[:description] || truncate_content(@doc[:content].gsub(/[#*`]/, '').strip, 155)
      @content = settings.markdown_renderer.render(@doc[:content])
      erb :documentation
    end

    get '/blog' do
      @page_title = 'Blog - PTD.dev'
      @page_description = 'Read about Polyglot Transpilation Development, AI-powered code ' \
                           'conversion, and native performance optimization.'
      @posts = settings.content_manager.get_blog_posts
      erb :blog_index
    end

    # New date-based blog post route
    get '/blog/:year/:month/:day/:slug' do
      year = params[:year]
      month = params[:month]
      day = params[:day]
      slug = params[:slug]

      @post = settings.content_manager.get_blog_post_by_date_slug(year, month, day, slug)
      halt 404 unless @post

      @page_title = "#{@post[:title]} - PTD.dev Blog"
      @page_description = @post[:description] || truncate_content(@post[:content].gsub(/[#*`]/, '').strip, 155)
      @post_url = "https://ptd.dev#{request.path_info}"
      @post_author = @post[:author] || 'Sebastian Buza'
      @post_published = @post[:created_at] || @post[:date]
      @content = settings.markdown_renderer.render(@post[:content])
      erb :blog_post
    end

    # Keep legacy route for backward compatibility (redirects to new URL)
    get '/blog/:slug' do
      slug = params[:slug]
      @post = settings.content_manager.get_blog_post(slug)

      if @post
        # Redirect to the new date-based URL
        redirect "/blog/#{@post[:date_slug]}", 301
      else
        halt 404
      end
    end

    # API endpoints for site management
    get '/api/health' do
      content_type :json
      {
        status: 'ok',
        timestamp: Time.now.iso8601,
        environment: ENV['RACK_ENV'] || 'development'
      }.to_json
    end

    get '/api/content/stats' do
      content_type :json
      settings.content_manager.get_stats.to_json
    end

    # Development endpoint to reload content
    post '/api/content/reload' do
      halt 403 unless development?

      content_type :json
      settings.content_manager.reload_content
      { status: 'reloaded', timestamp: Time.now.iso8601 }.to_json
    end

    # Error handlers
    not_found do
      @page_title = 'Page Not Found - PTD.dev'
      erb :not_found
    end

    error do
      @page_title = 'Error - PTD.dev'
      @error = env['sinatra.error']
      erb :error
    end

    # Helper methods
    helpers do
      def nav_link(path, text, options = {})
        css_class = request.path_info == path ? 'nav-link active' : 'nav-link'
        css_class += " #{options[:class]}" if options[:class]
        # NOTE: text contains HTML icons, so we don't escape it
        # Path and css_class are safe, no need to escape them
        "<a href=\"#{path}\" class=\"#{css_class}\">#{text}</a>"
      end

      def format_date(date)
        date.strftime('%B %d, %Y')
      end

      def truncate_content(content, length = 150)
        return content if content.length <= length

        content[0...length].gsub(/\s\w+\s*$/, '...').strip
      end

      def development?
        ENV['RACK_ENV'] == 'development' || ENV['SINATRA_ENV'] == 'development'
      end

      def production?
        ENV['RACK_ENV'] == 'production'
      end
    end
  end
end
