require 'redcarpet'
require 'coderay'

module PtdDev
  module Utils
    class MarkdownRenderer
      def initialize
        @renderer = create_renderer
        @markdown = Redcarpet::Markdown.new(@renderer, markdown_options)
      end

      def render(content)
        @markdown.render(content)
      end

      private

      def create_renderer
        Class.new(Redcarpet::Render::HTML) do
          def initialize(options = {})
            super(options.merge(
              filter_html: false,
              no_images: false,
              no_links: false,
              no_styles: false,
              safe_links_only: true,
              with_toc_data: true,
              hard_wrap: false,
              link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
            ))
          end

          def block_code(code, language)
            if language && !language.empty?
              coderay_highlight(code, language)
            else
              "<pre><code>#{escape_html(code)}</code></pre>"
            end
          end

          def header(text, header_level)
            anchor = text.downcase.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-')
            "<h#{header_level} id=\"#{anchor}\">#{text}</h#{header_level}>"
          end

          def table(header, body)
            "<div class=\"table-responsive\"><table class=\"table table-striped\">#{header}#{body}</table></div>"
          end

          def link(link, title, content)
            title_attr = title ? " title=\"#{escape_html(title)}\"" : ''

            if external_link?(link)
              "<a href=\"#{escape_html(link)}\"#{title_attr} target=\"_blank\" rel=\"noopener noreferrer\">#{content}</a>"
            else
              "<a href=\"#{escape_html(link)}\"#{title_attr}>#{content}</a>"
            end
          end

          def image(link, title, alt_text)
            title_attr = title ? " title=\"#{escape_html(title)}\"" : ''
            "<img src=\"#{escape_html(link)}\" alt=\"#{escape_html(alt_text)}\"#{title_attr} class=\"img-fluid\">"
          end

          def blockquote(quote)
            "<blockquote class=\"blockquote\">#{quote}</blockquote>"
          end

          private

          def coderay_highlight(code, language)
            # Map common language names to CodeRay-supported ones
            lang = normalize_language(language)

            begin
              CodeRay.scan(code, lang).html(
                css: :class,
                wrap: :div,
                line_numbers: false
              )
            rescue StandardError
              # Fallback to plain text if language not supported
              "<pre><code>#{escape_html(code)}</code></pre>"
            end
          end

          def normalize_language(language)
            case language.downcase
            when 'rb', 'ruby'
              :ruby
            when 'rs', 'rust'
              :rust
            when 'js', 'javascript'
              :javascript
            when 'ts', 'typescript'
              :typescript
            when 'py', 'python'
              :python
            when 'sh', 'bash', 'shell'
              :bash
            when 'yml', 'yaml'
              :yaml
            when 'json'
              :json
            when 'xml'
              :xml
            when 'html'
              :html
            when 'css'
              :css
            when 'sql'
              :sql
            when 'c'
              :c
            when 'cpp', 'c++'
              :cpp
            when 'java'
              :java
            when 'go'
              :go
            else
              language.to_sym
            end
          end

          def external_link?(link)
            link.start_with?('http://') || link.start_with?('https://')
          end

          def escape_html(text)
            text.to_s
                .gsub('&', '&amp;')
                .gsub('<', '&lt;')
                .gsub('>', '&gt;')
                .gsub('"', '&quot;')
                .gsub("'", '&#39;')
          end
        end.new
      end

      def markdown_options
        {
          autolink: true,
          tables: true,
          fenced_code_blocks: true,
          strikethrough: true,
          superscript: true,
          underline: true,
          highlight: true,
          footnotes: true,
          space_after_headers: true,
          no_intra_emphasis: true,
          disable_indented_code_blocks: false
        }
      end
    end
  end
end
