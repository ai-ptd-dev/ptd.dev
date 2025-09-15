# PTD Ruby CLI Boilerplate

> **Reference Implementation:** Ruby CLI demonstrating Polyglot Transpilation Development patterns

This project showcases best practices for building a Ruby CLI that can be transpiled to other languages like Rust for improved performance.

## Purpose

**This is a boilerplate/example project.** Fork it to:
- Learn Ruby CLI development best practices
- See clean architecture patterns for command-line tools  
- Use as a template for your own CLI applications
- Understand how to structure code for future transpilation

## Project Structure

```
├── src/
│   ├── cli.rb              # Main CLI entry point with Thor
│   ├── commands/
│   │   ├── hello.rb        # Example greeting command
│   │   ├── version.rb      # Version information command
│   │   └── benchmark.rb    # Performance benchmarking
│   └── utils/
│       ├── logger.rb       # Logging utilities
│       └── file_handler.rb # File operations
├── spec/
│   ├── ruby/               # RSpec tests
│   │   ├── hello_spec.rb
│   │   ├── version_spec.rb
│   │   ├── benchmark_spec.rb
│   │   ├── logger_spec.rb
│   │   └── file_handler_spec.rb
│   └── spec_helper.rb
├── bin/
│   └── ptd-ruby            # Ruby executable
└── Gemfile                 # Ruby dependencies
```

## Quick Start

```bash
# Clone the boilerplate
git clone https://github.com/ai-ptd-dev/ptd-ruby-cli
cd ptd-ruby-cli

# Install Ruby dependencies
bundle install

# Run the CLI
./bin/ptd-ruby hello "World"
./bin/ptd-ruby version
./bin/ptd-ruby benchmark 1000

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## Available Commands

### Hello Command
Greet someone with a personalized message:
```bash
# Basic greeting
./bin/ptd-ruby hello "Alice"

# Uppercase greeting
./bin/ptd-ruby hello "Bob" --uppercase

# Repeat greeting
./bin/ptd-ruby hello "Charlie" --repeat 3
```

### Version Command
Display version information:
```bash
# Formatted output
./bin/ptd-ruby version

# JSON output
./bin/ptd-ruby version --json
```

### Benchmark Command
Run performance benchmarks:
```bash
# Default console output
./bin/ptd-ruby benchmark 1000

# JSON output for analysis
./bin/ptd-ruby benchmark 1000 --output json

# CSV output for spreadsheets
./bin/ptd-ruby benchmark 1000 --output csv

# Verbose mode
./bin/ptd-ruby benchmark 1000 --verbose
```

### Process Command
Process JSON files:
```bash
# Process a JSON file
./bin/ptd-ruby process data.json

# Pretty print output
./bin/ptd-ruby process data.json --pretty

# Show processing statistics
./bin/ptd-ruby process data.json --stats
```

## Features Demonstrated

### Command Structure
- Clean command organization using Thor
- Option parsing with type validation
- Subcommands with descriptions
- Default values and aliases

### Utilities
- **Logger**: Colored output, log levels, timing helpers, progress bars
- **FileHandler**: JSON/YAML/CSV support, atomic writes, checksums

### Testing
- Comprehensive RSpec test suite
- Test helpers for capturing output
- Mock and stub examples
- Edge case coverage

### Best Practices
- Modular architecture
- Error handling patterns
- Configuration management
- Performance benchmarking

## Development

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/ruby/hello_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

### Code Quality
```bash
# Run Rubocop linter
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Check specific file
bundle exec rubocop src/cli.rb
```

## Customizing This Boilerplate

1. **Fork this repository**
2. **Modify Ruby source files** in `src/`
3. **Add your CLI commands** following the existing patterns
4. **Update tests** in `spec/ruby/`
5. **Run tests and linter** to ensure quality
6. **Build your CLI tool!**

### Adding a New Command

1. Create command file in `src/commands/`:
```ruby
# src/commands/mycommand.rb
module PTD
  module Commands
    class MyCommand
      def initialize(options = {})
        @options = options
      end
      
      def execute
        # Your command logic here
      end
    end
  end
end
```

2. Register in `src/cli.rb`:
```ruby
desc "mycommand", "Description of your command"
option :myoption, type: :string, desc: "Option description"
def mycommand
  command = Commands::MyCommand.new(options)
  command.execute
end
```

3. Add tests in `spec/ruby/mycommand_spec.rb`

## Architecture Decisions

### Why Thor?
Thor provides a clean DSL for building CLIs with automatic help generation, option parsing, and subcommand support.

### Modular Commands
Each command is a separate class for:
- Testability
- Reusability  
- Clear separation of concerns
- Easy transpilation

### Utility Classes
Shared functionality in utils/ for:
- Consistent logging
- File operations
- Future extensibility

## PTD Methodology

This project is designed for **Polyglot Transpilation Development**:
- Write expressive Ruby code
- Structure for easy transpilation
- Maintain clean architecture
- Optimize for both development speed and runtime performance

When ready, this codebase can be transpiled to languages like Rust for:
- 10-50x performance improvement
- Native binary distribution
- Lower memory footprint
- Deployment without Ruby runtime

## Contributing

1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Ensure tests pass and Rubocop is happy
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Resources

- [Thor Documentation](http://whatisthor.com/)
- [RSpec Documentation](https://rspec.info/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [PTD Methodology](https://github.com/ai-ptd-dev/ptd-methodology)

---

**Ready to build your CLI?** Fork this repo and start coding! 🚀