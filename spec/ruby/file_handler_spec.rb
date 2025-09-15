require 'spec_helper'
require 'tempfile'
require 'fileutils'
require_relative '../../src/utils/file_handler'

RSpec.describe PTD::Utils::FileHandler do
  let(:temp_dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '.read and .write' do
    context 'JSON format' do
      let(:filepath) { File.join(temp_dir, 'test.json') }
      let(:data) { { name: 'Test', value: 42, items: [1, 2, 3] } }

      it 'writes and reads JSON data correctly' do
        described_class.write(filepath, data, format: :json)
        expect(File).to exist(filepath)

        read_data = described_class.read(filepath, format: :json)
        expect(read_data[:name]).to eq(data[:name])
        expect(read_data[:value]).to eq(data[:value])
        expect(read_data[:items]).to eq(data[:items])
      end

      it 'writes pretty JSON when specified' do
        described_class.write(filepath, data, format: :json, pretty: true)
        content = File.read(filepath)

        expect(content).to include("\n")
        expect(content).to include('  ')
      end

      it 'writes compact JSON when pretty is false' do
        described_class.write(filepath, data, format: :json, pretty: false)
        content = File.read(filepath)

        expect(content).not_to include("\n")
      end
    end

    context 'YAML format' do
      let(:filepath) { File.join(temp_dir, 'test.yaml') }
      let(:data) { { config: { host: 'localhost', port: 3000 } } }

      it 'writes and reads YAML data correctly' do
        described_class.write(filepath, data, format: :yaml)
        read_data = described_class.read(filepath, format: :yaml)

        expect(read_data).to be_a(Hash)
        expect(read_data.dig(:config, :host)).to eq('localhost')
        expect(read_data.dig(:config, :port)).to eq(3000)
      end
    end

    context 'CSV format' do
      let(:filepath) { File.join(temp_dir, 'test.csv') }
      let(:data) do
        [
          { name: 'Alice', age: 30, city: 'NYC' },
          { name: 'Bob', age: 25, city: 'LA' }
        ]
      end

      it 'writes and reads CSV data correctly' do
        described_class.write(filepath, data, format: :csv)
        read_data = described_class.read(filepath, format: :csv)

        expect(read_data.size).to eq(2)
        expect(read_data[0]['name']).to eq('Alice')
        expect(read_data[0]['age']).to eq('30')
        expect(read_data[1]['name']).to eq('Bob')
      end
    end

    context 'text format' do
      let(:filepath) { File.join(temp_dir, 'test.txt') }
      let(:content) { "Plain text content\nWith multiple lines" }

      it 'writes and reads plain text' do
        described_class.write(filepath, content)
        read_content = described_class.read(filepath)

        expect(read_content).to eq(content)
      end
    end

    context 'format detection' do
      it 'automatically detects JSON format' do
        json_file = File.join(temp_dir, 'auto.json')
        described_class.write(json_file, { test: true })

        result = described_class.read(json_file)
        expect(result).to be_a(Hash)
        expect(result[:test]).to be true
      end

      it 'automatically detects YAML format' do
        yaml_file = File.join(temp_dir, 'auto.yaml')
        described_class.write(yaml_file, { test: true })

        result = described_class.read(yaml_file)
        expect(result).to be_a(Hash)
      end

      it 'automatically detects CSV format' do
        csv_file = File.join(temp_dir, 'auto.csv')
        described_class.write(csv_file, [{ a: 1, b: 2 }])

        result = described_class.read(csv_file)
        expect(result).to be_an(Array)
      end
    end
  end

  describe '.copy' do
    let(:source) { File.join(temp_dir, 'source.txt') }
    let(:dest) { File.join(temp_dir, 'subdir', 'dest.txt') }

    before do
      File.write(source, 'test content')
    end

    it 'copies file to destination' do
      described_class.copy(source, dest)

      expect(File).to exist(dest)
      expect(File.read(dest)).to eq('test content')
      expect(File).to exist(source) # Original should still exist
    end

    it 'creates destination directory if needed' do
      described_class.copy(source, dest, create_dirs: true)

      expect(File).to exist(dest)
    end

    it 'raises error if source does not exist' do
      expect do
        described_class.copy('/nonexistent/file.txt', dest)
      end.to raise_error(PTD::Utils::FileHandler::FileError, /Source file not found/)
    end
  end

  describe '.move' do
    let(:source) { File.join(temp_dir, 'source.txt') }
    let(:dest) { File.join(temp_dir, 'moved.txt') }

    before do
      File.write(source, 'move me')
    end

    it 'moves file to destination' do
      described_class.move(source, dest)

      expect(File).not_to exist(source)
      expect(File).to exist(dest)
      expect(File.read(dest)).to eq('move me')
    end

    it 'creates destination directory if needed' do
      nested_dest = File.join(temp_dir, 'nested', 'dir', 'file.txt')
      described_class.move(source, nested_dest, create_dirs: true)

      expect(File).to exist(nested_dest)
    end
  end

  describe '.delete' do
    let(:filepath) { File.join(temp_dir, 'delete_me.txt') }

    it 'deletes existing file' do
      File.write(filepath, 'temporary')

      result = described_class.delete(filepath)
      expect(result).to be true
      expect(File).not_to exist(filepath)
    end

    it 'returns false for non-existent file' do
      result = described_class.delete('/nonexistent/file.txt')
      expect(result).to be false
    end
  end

  describe '.exists?' do
    it 'returns true for existing file' do
      filepath = File.join(temp_dir, 'exists.txt')
      File.write(filepath, 'content')

      expect(described_class.exists?(filepath)).to be true
    end

    it 'returns false for non-existent file' do
      expect(described_class.exists?('/nonexistent/file.txt')).to be false
    end
  end

  describe '.size' do
    let(:filepath) { File.join(temp_dir, 'sized.txt') }

    it 'returns file size in bytes' do
      content = 'Hello World'
      File.write(filepath, content)

      expect(described_class.size(filepath)).to eq(content.bytesize)
    end

    it 'raises error for non-existent file' do
      expect do
        described_class.size('/nonexistent/file.txt')
      end.to raise_error(PTD::Utils::FileHandler::FileError)
    end
  end

  describe '.checksum' do
    let(:filepath) { File.join(temp_dir, 'checksum.txt') }

    before do
      File.write(filepath, 'Hello World')
    end

    it 'calculates SHA256 checksum by default' do
      checksum = described_class.checksum(filepath)
      expect(checksum).to be_a(String)
      expect(checksum.length).to eq(64) # SHA256 is 64 hex chars
    end

    it 'calculates MD5 checksum' do
      checksum = described_class.checksum(filepath, algorithm: :md5)
      expect(checksum.length).to eq(32) # MD5 is 32 hex chars
    end

    it 'calculates SHA1 checksum' do
      checksum = described_class.checksum(filepath, algorithm: :sha1)
      expect(checksum.length).to eq(40) # SHA1 is 40 hex chars
    end

    it 'calculates SHA512 checksum' do
      checksum = described_class.checksum(filepath, algorithm: :sha512)
      expect(checksum.length).to eq(128) # SHA512 is 128 hex chars
    end

    it 'raises error for unsupported algorithm' do
      expect do
        described_class.checksum(filepath, algorithm: :invalid)
      end.to raise_error(ArgumentError, /Unsupported algorithm/)
    end
  end

  describe '.stats' do
    let(:filepath) { File.join(temp_dir, 'stats.txt') }

    before do
      File.write(filepath, 'test content')
    end

    it 'returns comprehensive file statistics' do
      stats = described_class.stats(filepath)

      expect(stats[:size]).to eq(12)
      expect(stats[:file]).to be true
      expect(stats[:directory]).to be false
      expect(stats[:readable]).to be true
      expect(stats[:writable]).to be true
      expect(stats[:modified_at]).to be_a(Time)
      expect(stats[:created_at]).to be_a(Time)
      expect(stats[:accessed_at]).to be_a(Time)
      expect(stats[:permissions]).to match(/\d{3}/)
    end
  end

  describe '.atomic_write' do
    let(:filepath) { File.join(temp_dir, 'atomic.json') }
    let(:data) { { atomic: true, value: 42 } }

    it 'writes file atomically' do
      described_class.atomic_write(filepath, data, format: :json)

      expect(File).to exist(filepath)
      read_data = described_class.read(filepath, format: :json)
      expect(read_data[:atomic]).to be true
    end

    it 'cleans up temp file even on failure' do
      allow(FileUtils).to receive(:mv).and_raise('Mock error')

      expect do
        described_class.atomic_write(filepath, data)
      end.to raise_error('Mock error')

      # Check no temp files remain
      temp_files = Dir.glob(File.join(temp_dir, '*.tmp.*'))
      expect(temp_files).to be_empty
    end
  end

  describe 'error handling' do
    it 'raises FileError for non-existent file reads' do
      expect do
        described_class.read('/nonexistent/file.txt')
      end.to raise_error(PTD::Utils::FileHandler::FileError, /File not found/)
    end

    it 'raises FileError for invalid JSON' do
      filepath = File.join(temp_dir, 'invalid.json')
      File.write(filepath, '{invalid json}')

      expect do
        described_class.read(filepath, format: :json)
      end.to raise_error(PTD::Utils::FileHandler::FileError, /Invalid JSON/)
    end

    it 'raises FileError for invalid YAML' do
      filepath = File.join(temp_dir, 'invalid.yaml')
      File.write(filepath, ":\n  invalid: yaml: structure:")

      expect do
        described_class.read(filepath, format: :yaml)
      end.to raise_error(PTD::Utils::FileHandler::FileError, /Invalid YAML/)
    end

    it 'raises FileError for invalid CSV' do
      filepath = File.join(temp_dir, 'invalid.csv')
      File.write(filepath, '"unclosed quote,data')

      expect do
        described_class.read(filepath, format: :csv)
      end.to raise_error(PTD::Utils::FileHandler::FileError, /Invalid CSV/)
    end
  end
end
