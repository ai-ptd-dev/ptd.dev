require 'json'
require 'yaml'
require 'csv'
require 'fileutils'
require 'digest'

module BasicCli
  module Utils
    class FileHandler
      class FileError < StandardError; end
      class UnsupportedFormatError < FileError; end

      SUPPORTED_FORMATS = %w[.json .yaml .yml .csv .txt .log].freeze

      def self.read(filepath, format: nil)
        raise FileError, "File not found: #{filepath}" unless File.exist?(filepath)

        format ||= detect_format(filepath)
        content = File.read(filepath)

        case format
        when :json
          parse_json(content)
        when :yaml
          parse_yaml(content)
        when :csv
          parse_csv(content)
        else
          content
        end
      rescue StandardError => e
        raise FileError, "Failed to read #{filepath}: #{e.message}"
      end

      def self.write(filepath, data, format: nil, pretty: true)
        format ||= detect_format(filepath)

        FileUtils.mkdir_p(File.dirname(filepath))

        content = case format
                  when :json
                    pretty ? JSON.pretty_generate(data) : data.to_json
                  when :yaml
                    data.to_yaml
                  when :csv
                    generate_csv(data)
                  else
                    data.to_s
                  end

        File.write(filepath, content)
        true
      rescue StandardError => e
        raise FileError, "Failed to write #{filepath}: #{e.message}"
      end

      def self.copy(source, destination, create_dirs: true)
        raise FileError, "Source file not found: #{source}" unless File.exist?(source)

        FileUtils.mkdir_p(File.dirname(destination)) if create_dirs

        FileUtils.cp(source, destination)
        true
      rescue StandardError => e
        raise FileError, "Failed to copy file: #{e.message}"
      end

      def self.move(source, destination, create_dirs: true)
        raise FileError, "Source file not found: #{source}" unless File.exist?(source)

        FileUtils.mkdir_p(File.dirname(destination)) if create_dirs

        FileUtils.mv(source, destination)
        true
      rescue StandardError => e
        raise FileError, "Failed to move file: #{e.message}"
      end

      def self.delete(filepath)
        return false unless File.exist?(filepath)

        File.delete(filepath)
        true
      rescue StandardError => e
        raise FileError, "Failed to delete #{filepath}: #{e.message}"
      end

      def self.exists?(filepath)
        File.exist?(filepath)
      end

      def self.size(filepath)
        raise FileError, "File not found: #{filepath}" unless File.exist?(filepath)

        File.size(filepath)
      end

      def self.checksum(filepath, algorithm: :sha256)
        raise FileError, "File not found: #{filepath}" unless File.exist?(filepath)

        digest = case algorithm
                 when :md5
                   Digest::MD5
                 when :sha1
                   Digest::SHA1
                 when :sha256
                   Digest::SHA256
                 when :sha512
                   Digest::SHA512
                 else
                   raise ArgumentError, "Unsupported algorithm: #{algorithm}"
                 end

        digest.file(filepath).hexdigest
      end

      def self.stats(filepath)
        raise FileError, "File not found: #{filepath}" unless File.exist?(filepath)

        stat = File.stat(filepath)
        {
          size: stat.size,
          modified_at: stat.mtime,
          created_at: stat.ctime,
          accessed_at: stat.atime,
          permissions: stat.mode.to_s(8)[-3..],
          directory: stat.directory?,
          file: stat.file?,
          readable: stat.readable?,
          writable: stat.writable?,
          executable: stat.executable?
        }
      end

      def self.watch(filepath)
        raise FileError, "File not found: #{filepath}" unless File.exist?(filepath)

        last_mtime = File.mtime(filepath)

        loop do
          sleep 0.1
          current_mtime = File.mtime(filepath)

          if current_mtime > last_mtime
            yield(filepath, current_mtime)
            last_mtime = current_mtime
          end
        end
      end

      def self.atomic_write(filepath, data, format: nil)
        temp_file = "#{filepath}.tmp.#{Process.pid}"

        begin
          write(temp_file, data, format: format)
          FileUtils.mv(temp_file, filepath)
          true
        ensure
          FileUtils.rm_f(temp_file)
        end
      end

      def self.detect_format(filepath)
        ext = File.extname(filepath).downcase

        case ext
        when '.json'
          :json
        when '.yaml', '.yml'
          :yaml
        when '.csv'
          :csv
        else
          :text
        end
      end

      def self.parse_json(content)
        JSON.parse(content, symbolize_names: true)
      rescue JSON::ParserError => e
        raise FileError, "Invalid JSON: #{e.message}"
      end

      def self.parse_yaml(content)
        YAML.safe_load(content, permitted_classes: [Symbol, Date, Time], aliases: true)
      rescue Psych::SyntaxError => e
        raise FileError, "Invalid YAML: #{e.message}"
      end

      def self.parse_csv(content)
        CSV.parse(content, headers: true).map(&:to_h)
      rescue CSV::MalformedCSVError => e
        raise FileError, "Invalid CSV: #{e.message}"
      end

      def self.generate_csv(data)
        return '' if data.empty?

        if data.is_a?(Array) && data.first.is_a?(Hash)
          CSV.generate do |csv|
            csv << data.first.keys
            data.each { |row| csv << row.values }
          end
        else
          data.to_s
        end
      end
    end
  end
end
