require 'spec_helper'

RSpec.describe 'Pages Functionality' do
  let(:content_manager) { PtdDev::Utils::ContentManager.new }

  describe 'Page content structure' do
    context 'home page' do
      let(:home_page) { content_manager.get_page('home') }

      it 'contains hero section' do
        expect(home_page[:content]).to include('hero-section')
        expect(home_page[:content]).to include('Write Expressive')
        expect(home_page[:content]).to include('Deploy Native')
      end

      it 'contains performance statistics' do
        expect(home_page[:content]).to include('250x')
        expect(home_page[:content]).to include('Faster Startup')
        expect(home_page[:content]).to include('90%')
        expect(home_page[:content]).to include('Memory Reduction')
      end

      it 'contains feature cards' do
        expect(home_page[:content]).to include('feature-card')
        expect(home_page[:content]).to include('Multiple Languages')
        expect(home_page[:content]).to include('AI-Powered Transpilation')
        expect(home_page[:content]).to include('Native Performance')
      end

      it 'contains call-to-action buttons' do
        expect(home_page[:content]).to include('Get Started')
        expect(home_page[:content]).to include('href="/docs"')
        expect(home_page[:content]).to include('Explore on GitHub')
      end

      it 'contains code examples' do
        expect(home_page[:content]).to include('class TodoManager')
        expect(home_page[:content]).to include('impl TodoManager')
        expect(home_page[:content]).to include('Ruby, Python, or JavaScript')
        expect(home_page[:content]).to include('Rust')
      end
    end

    context 'about page' do
      let(:about_page) { content_manager.get_page('about') }

      it 'contains main sections' do
        expect(about_page[:content]).to include('The Problem')
        expect(about_page[:content]).to include('The PTD Solution')
        expect(about_page[:content]).to include('How It Works')
      end

      it 'contains development vs production comparison' do
        expect(about_page[:content]).to include('Development Phase')
        expect(about_page[:content]).to include('Production Phase')
        expect(about_page[:content]).to include('Write in Ruby')
        expect(about_page[:content]).to include('Deploy Rust binary')
      end

      it 'contains creator information' do
        expect(about_page[:content]).to include('Sebastian Buza')
        expect(about_page[:content]).to include('github.com/sebyx07')
      end

      it 'contains process steps' do
        expect(about_page[:content]).to include('Write in Your Language')
        expect(about_page[:content]).to include('AI Transpilation')
        expect(about_page[:content]).to include('Test Parity')
        expect(about_page[:content]).to include('Deploy Native')
      end
    end

    context 'contact page' do
      let(:contact_page) { content_manager.get_page('contact') }

      it 'exists and has content' do
        expect(contact_page).not_to be_nil
        expect(contact_page[:content]).to be_a(String)
        expect(contact_page[:content]).not_to be_empty
      end

      it 'has appropriate title' do
        expect(contact_page[:title]).to include('Contact')
      end
    end
  end

  describe 'Page metadata consistency' do
    it 'all pages have consistent metadata structure' do
      %w[home about contact].each do |slug|
        page = content_manager.get_page(slug)

        expect(page).to have_key(:slug)
        expect(page).to have_key(:title)
        expect(page).to have_key(:description)
        expect(page).to have_key(:content)
        expect(page).to have_key(:updated_at)

        expect(page[:slug]).to eq(slug)
        expect(page[:title]).to be_a(String)
        expect(page[:content]).to be_a(String)
        expect(page[:updated_at]).to be_a(Time)
      end
    end

    it 'pages have appropriate SEO metadata' do
      home_page = content_manager.get_page('home')
      about_page = content_manager.get_page('about')

      expect(home_page[:description]).to include('PTD')
      expect(home_page[:description]).to include('transpilation')

      expect(about_page[:description]).to include('PTD paradigm')
      expect(about_page[:description]).to include('development')
    end
  end

  describe 'Page content validation' do
    it 'ensures pages contain valid HTML structure' do
      %w[home about contact].each do |slug|
        page = content_manager.get_page(slug)
        content = page[:content]

        # Check for basic HTML structure
        expect(content).to match(/<[^>]+>/) # Contains HTML tags

        # Check for proper nesting (basic validation)
        open_divs = content.scan(/<div[^>]*>/).length
        close_divs = content.scan('</div>').length
        expect(open_divs).to eq(close_divs), "Mismatched div tags in #{slug} page"
      end
    end

    it 'ensures pages use Bootstrap CSS classes appropriately' do
      home_page = content_manager.get_page('home')
      about_page = content_manager.get_page('about')

      bootstrap_classes = %w[container row col-md col-lg btn card]

      bootstrap_classes.each do |css_class|
        expect(home_page[:content]).to include(css_class), "Home page missing #{css_class} class"
      end

      expect(about_page[:content]).to include('container')
      expect(about_page[:content]).to include('row')
    end

    it 'ensures pages have proper accessibility attributes' do
      home_page = content_manager.get_page('home')

      # Check for alt attributes on images (if any)
      expect(home_page[:content]).to include('alt=') if home_page[:content].include?('<img')

      # Check for proper heading hierarchy
      expect(home_page[:content]).to include('<h1')
    end
  end

  describe 'Page performance considerations' do
    it 'pages do not contain excessively large content' do
      %w[home about contact].each do |slug|
        page = content_manager.get_page(slug)
        content_size = page[:content].bytesize

        # Reasonable size limit for page content (100KB)
        expect(content_size).to be < 100_000, "#{slug} page content is too large: #{content_size} bytes"
      end
    end

    it 'pages load quickly from content manager' do
      start_time = Time.now

      10.times do
        content_manager.get_page('home')
        content_manager.get_page('about')
        content_manager.get_page('contact')
      end

      end_time = Time.now
      total_time = end_time - start_time

      # Should be able to load all pages 10 times in under 1 second
      expect(total_time).to be < 1.0, "Page loading too slow: #{total_time} seconds"
    end
  end

  describe 'Page content security' do
    it 'pages do not contain potentially dangerous content' do
      %w[home about contact].each do |slug|
        page = content_manager.get_page(slug)
        content = page[:content]

        # Check for potentially dangerous patterns
        expect(content).not_to include('<script'), "#{slug} page contains script tags"
        expect(content).not_to include('javascript:'), "#{slug} page contains javascript: URLs"
        expect(content).not_to include('onload='), "#{slug} page contains onload attributes"
        expect(content).not_to include('onclick='), "#{slug} page contains onclick attributes"
      end
    end

    it 'external links have proper security attributes' do
      about_page = content_manager.get_page('about')

      if about_page[:content].include?('https://')
        # External links should have target="_blank" and rel="noopener noreferrer"
        # This is handled by the markdown renderer, but pages might have direct HTML links
        external_links = about_page[:content].scan(%r{<a[^>]*href=["']https?://[^"']*["'][^>]*>})

        external_links.each do |link|
          if link.include?('target="_blank"')
            expect(link).to include('rel='), "External link missing rel attribute: #{link}"
          end
        end
      end
    end
  end
end
