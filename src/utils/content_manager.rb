require 'yaml'

module PtdDev
  module Utils
    class ContentManager
      attr_reader :pages, :blog_posts, :documentation

      def initialize
        @content_dir = File.expand_path('../../content', __dir__)
        @pages = {}
        @blog_posts = {}
        @documentation = {}
        load_content
      end

      def get_page(slug)
        @pages[slug.to_s]
      end

      def get_blog_post(slug)
        @blog_posts[slug.to_s]
      end

      def get_blog_post_by_date_slug(year, month, day, slug)
        # Find post that matches both the date and slug
        @blog_posts.values.find do |post|
          post[:slug] == slug &&
            post[:date].year == year.to_i &&
            post[:date].month == month.to_i &&
            post[:date].day == day.to_i
        end
      end

      def get_blog_posts(limit = nil)
        posts = @blog_posts.values.sort_by { |post| post[:date] }.reverse
        limit ? posts.first(limit) : posts
      end

      def get_documentation(category, slug)
        @documentation.dig(category.to_s, slug.to_s)
      end

      def get_documentation_index
        @documentation.transform_values do |category|
          category.values.map { |doc| doc.slice(:title, :slug, :description) }
        end
      end

      def get_stats
        {
          pages: @pages.size,
          blog_posts: @blog_posts.size,
          documentation: @documentation.values.sum(&:size),
          last_updated: Time.now.iso8601
        }
      end

      def reload_content
        @pages.clear
        @blog_posts.clear
        @documentation.clear
        load_content
      end

      private

      def load_content
        load_pages
        load_blog_posts
        load_documentation
      end

      def load_pages
        pages_dir = File.join(@content_dir, 'pages')
        return unless Dir.exist?(pages_dir)

        Dir.glob(File.join(pages_dir, '*.html')).each do |file|
          slug = File.basename(file, '.html')
          content = File.read(file)

          # Extract frontmatter if present
          if content.start_with?('---')
            parts = content.split('---', 3)
            frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
            html_content = parts[2].strip
          else
            frontmatter = {}
            html_content = content
          end

          @pages[slug] = {
            slug: slug,
            title: frontmatter['title'] || slug.capitalize,
            description: frontmatter['description'],
            content: html_content,
            updated_at: File.mtime(file)
          }
        end
      end

      def load_blog_posts
        blog_dir = File.join(@content_dir, 'blog')
        return unless Dir.exist?(blog_dir)

        Dir.glob(File.join(blog_dir, '*.md')).each do |file|
          filename = File.basename(file, '.md')

          # Handle timestamp-based filenames (YYYYMMDDHHMMSS_slug) or legacy date-based (YYYY-MM-DD-slug)
          slug = if filename.match?(/^\d{14}_/)
                   # New timestamp format: 20231215143022_my-post-title
                   filename.split('_', 2)[1]
                 elsif filename.match?(/^\d{4}-\d{2}-\d{2}-/)
                   # Legacy date format: 2023-12-15-my-post-title
                   filename.split('-', 4)[3..].join('-')
                 else
                   # Fallback: use entire filename as slug
                   filename
                 end

          content = File.read(file)

          # Extract frontmatter
          next unless content.start_with?('---')

          parts = content.split('---', 3)
          frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
          markdown_content = parts[2].strip

          # Skip files without frontmatter

          # Parse date from frontmatter, fallback to file modification time
          post_date = if frontmatter['date']
                        begin
                          Date.parse(frontmatter['date'].to_s)
                        rescue ArgumentError
                          Date.parse(File.mtime(file).to_s)
                        end
                      else
                        Date.parse(File.mtime(file).to_s)
                      end

          # Create URL slug with date prefix for uniqueness
          date_slug = "#{post_date.strftime('%Y/%m/%d')}/#{slug}"

          @blog_posts[slug] = {
            slug: slug,
            date_slug: date_slug, # Full path with date for URLs
            filename: filename,
            title: frontmatter['title'],
            description: frontmatter['description'],
            author: frontmatter['author'] || 'Sebastian Buza',
            date: post_date,
            created_at: frontmatter['created_at'],
            tags: frontmatter['tags'] || [],
            content: markdown_content,
            published: frontmatter['published'] != false,
            updated_at: File.mtime(file)
          }
        end

        # Filter out unpublished posts in production
        return if development?

        @blog_posts.select! { |_, post| post[:published] }
      end

      def load_documentation
        docs_dir = File.join(@content_dir, 'docs')
        return unless Dir.exist?(docs_dir)

        Dir.glob(File.join(docs_dir, '*')).each do |category_dir|
          next unless File.directory?(category_dir)

          category = File.basename(category_dir)
          @documentation[category] = {}

          Dir.glob(File.join(category_dir, '*.md')).each do |file|
            slug = File.basename(file, '.md')
            content = File.read(file)

            # Extract frontmatter
            if content.start_with?('---')
              parts = content.split('---', 3)
              frontmatter = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
              markdown_content = parts[2].strip
            else
              frontmatter = {}
              markdown_content = content
            end

            @documentation[category][slug] = {
              slug: slug,
              category: category,
              title: frontmatter['title'] || slug.gsub('-', ' ').capitalize,
              description: frontmatter['description'],
              order: frontmatter['order'] || 999,
              content: markdown_content,
              updated_at: File.mtime(file)
            }
          end

          # Sort by order
          @documentation[category] = @documentation[category]
                                     .sort_by { |_, doc| doc[:order] }
                                     .to_h
        end
      end

      def development?
        ENV['RACK_ENV'] == 'development' || ENV['SINATRA_ENV'] == 'development'
      end
    end
  end
end
