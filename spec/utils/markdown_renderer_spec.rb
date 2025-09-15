require 'spec_helper'

RSpec.describe PtdDev::Utils::MarkdownRenderer do
  let(:renderer) { described_class.new }

  describe '#render' do
    it 'converts markdown to HTML' do
      markdown = '# Hello World'
      html = renderer.render(markdown)
      expect(html).to include('<h1')
      expect(html).to include('Hello World')
    end

    it 'handles code blocks with syntax highlighting' do
      markdown = "```ruby\nputs 'Hello'\n```"
      html = renderer.render(markdown)
      expect(html).to include('CodeRay')
    end

    it 'creates tables with Bootstrap classes' do
      markdown = "| Header |\n|--------|\n| Cell   |"
      html = renderer.render(markdown)
      expect(html).to include('table-responsive')
      expect(html).to include('table table-striped')
    end

    it 'adds target="_blank" to external links' do
      markdown = '[External](https://example.com)'
      html = renderer.render(markdown)
      expect(html).to include('target="_blank"')
      expect(html).to include('rel="noopener noreferrer"')
    end

    it 'does not add target="_blank" to internal links' do
      markdown = '[Internal](/docs)'
      html = renderer.render(markdown)
      expect(html).not_to include('target="_blank"')
    end

    it 'adds Bootstrap classes to images' do
      markdown = '![Alt text](image.jpg)'
      html = renderer.render(markdown)
      expect(html).to include('img-fluid')
    end

    it 'adds Bootstrap classes to blockquotes' do
      markdown = '> This is a quote'
      html = renderer.render(markdown)
      expect(html).to include('blockquote')
    end

    it 'creates anchors for headers' do
      markdown = '# Hello World'
      html = renderer.render(markdown)
      expect(html).to include('id="hello-world"')
    end
  end
end
