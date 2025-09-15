require 'spec_helper'

RSpec.describe PtdDev::Utils::ContentManager do
  let(:content_manager) { described_class.new }

  describe '#get_page' do
    it 'returns page content for valid slug' do
      page = content_manager.get_page('home')
      expect(page).to be_a(Hash)
      expect(page[:slug]).to eq('home')
      expect(page[:title]).to include('PTD.dev')
    end

    it 'returns nil for invalid slug' do
      page = content_manager.get_page('nonexistent')
      expect(page).to be_nil
    end

    it 'loads all available pages' do
      expect(content_manager.pages).to have_key('home')
      expect(content_manager.pages).to have_key('about')
      expect(content_manager.pages).to have_key('contact')
    end

    it 'extracts frontmatter correctly from pages' do
      home_page = content_manager.get_page('home')
      expect(home_page[:title]).to be_a(String)
      expect(home_page[:description]).to be_a(String)
      expect(home_page[:content]).to be_a(String)
    end

    it 'handles pages without frontmatter' do
      # Create a temporary page without frontmatter for testing
      temp_content = '<h1>Test Page</h1><p>This is a test page without frontmatter.</p>'
      temp_file = File.join(content_manager.instance_variable_get(:@content_dir), 'pages', 'temp_test.html')

      begin
        File.write(temp_file, temp_content)
        content_manager.reload_content

        page = content_manager.get_page('temp_test')
        expect(page).to be_a(Hash)
        expect(page[:title]).to eq('Temp_test')
        expect(page[:content]).to eq(temp_content)
        expect(page[:description]).to be_nil
      ensure
        FileUtils.rm_f(temp_file)
        content_manager.reload_content
      end
    end

    it 'includes file modification timestamps' do
      page = content_manager.get_page('home')
      expect(page[:updated_at]).to be_a(Time)
      expect(page[:updated_at]).to be <= Time.now
    end

    it 'handles different page types correctly' do
      %w[home about contact].each do |slug|
        page = content_manager.get_page(slug)
        expect(page).to be_a(Hash)
        expect(page[:slug]).to eq(slug)
        expect(page[:content]).to be_a(String)
        expect(page[:content]).not_to be_empty
      end
    end

    it 'preserves HTML content structure' do
      about_page = content_manager.get_page('about')
      expect(about_page[:content]).to include('<div')
      expect(about_page[:content]).to include('<h1>')
      expect(about_page[:content]).to include('<p')
    end

    it 'handles special characters in content' do
      home_page = content_manager.get_page('home')
      expect(home_page[:content]).to include('&') # HTML entities should be preserved
    end
  end

  describe '#get_blog_posts' do
    it 'returns array of blog posts' do
      posts = content_manager.get_blog_posts
      expect(posts).to be_an(Array)
    end

    it 'returns posts sorted by date (newest first)' do
      posts = content_manager.get_blog_posts
      expect(posts.first[:date]).to be >= posts.last[:date] if posts.length > 1
    end

    it 'respects limit parameter' do
      posts = content_manager.get_blog_posts(1)
      expect(posts.length).to be <= 1
    end
  end

  describe '#get_documentation_index' do
    it 'returns documentation structure' do
      docs = content_manager.get_documentation_index
      expect(docs).to be_a(Hash)
    end

    it 'includes getting-started category' do
      docs = content_manager.get_documentation_index
      expect(docs).to have_key('getting-started')
    end
  end

  describe '#get_stats' do
    it 'returns content statistics' do
      stats = content_manager.get_stats
      expect(stats).to be_a(Hash)
      expect(stats).to have_key(:pages)
      expect(stats).to have_key(:blog_posts)
      expect(stats).to have_key(:documentation)
      expect(stats).to have_key(:last_updated)
    end

    it 'returns numeric values for counts' do
      stats = content_manager.get_stats
      expect(stats[:pages]).to be_a(Numeric)
      expect(stats[:blog_posts]).to be_a(Numeric)
      expect(stats[:documentation]).to be_a(Numeric)
    end
  end

  describe '#reload_content' do
    it 'reloads all content without error' do
      expect { content_manager.reload_content }.not_to raise_error
    end

    it 'clears existing content before reloading' do
      original_pages_count = content_manager.pages.size
      content_manager.reload_content
      expect(content_manager.pages.size).to eq(original_pages_count)
    end

    it 'reloads pages with updated content' do
      # Get original content
      original_page = content_manager.get_page('home')
      original_title = original_page[:title]

      # Reload and verify content is still there
      content_manager.reload_content
      reloaded_page = content_manager.get_page('home')
      expect(reloaded_page[:title]).to eq(original_title)
    end
  end

  describe 'Page loading edge cases' do
    let(:pages_dir) { File.join(content_manager.instance_variable_get(:@content_dir), 'pages') }

    it 'handles empty pages directory gracefully' do
      # Temporarily rename pages directory
      temp_dir = "#{pages_dir}_temp"
      File.rename(pages_dir, temp_dir) if Dir.exist?(pages_dir)

      begin
        content_manager.reload_content
        expect(content_manager.pages).to be_empty
      ensure
        File.rename(temp_dir, pages_dir) if Dir.exist?(temp_dir)
        content_manager.reload_content
      end
    end

    it 'skips non-HTML files in pages directory' do
      temp_file = File.join(pages_dir, 'test.txt')

      begin
        File.write(temp_file, 'This is not an HTML file')
        content_manager.reload_content
        expect(content_manager.get_page('test')).to be_nil
      ensure
        FileUtils.rm_f(temp_file)
        content_manager.reload_content
      end
    end

    it 'handles malformed YAML frontmatter gracefully' do
      temp_file = File.join(pages_dir, 'malformed.html')
      malformed_content = "---\ntitle: Unclosed quote '\ndescription: test\n---\n<h1>Test</h1>"

      begin
        File.write(temp_file, malformed_content)
        expect { content_manager.reload_content }.not_to raise_error

        page = content_manager.get_page('malformed')
        expect(page).to be_a(Hash)
        expect(page[:slug]).to eq('malformed')
      ensure
        FileUtils.rm_f(temp_file)
        content_manager.reload_content
      end
    end
  end

  describe 'Page metadata validation' do
    it 'ensures all pages have required fields' do
      content_manager.pages.each_value do |page|
        expect(page).to have_key(:slug)
        expect(page).to have_key(:title)
        expect(page).to have_key(:content)
        expect(page).to have_key(:updated_at)

        expect(page[:slug]).to be_a(String)
        expect(page[:title]).to be_a(String)
        expect(page[:content]).to be_a(String)
        expect(page[:updated_at]).to be_a(Time)
      end
    end

    it 'generates appropriate default titles for pages without frontmatter' do
      # Test that slug is capitalized as default title
      expect(content_manager.get_page('home')[:title]).not_to eq('Home') # Should have custom title

      # Create a test page without title in frontmatter
      temp_file = File.join(content_manager.instance_variable_get(:@content_dir), 'pages', 'test_default.html')
      content_without_title = "---\ndescription: Test page\n---\n<h1>Test</h1>"

      begin
        File.write(temp_file, content_without_title)
        content_manager.reload_content

        page = content_manager.get_page('test_default')
        expect(page[:title]).to eq('Test_default')
      ensure
        FileUtils.rm_f(temp_file)
        content_manager.reload_content
      end
    end
  end
end
