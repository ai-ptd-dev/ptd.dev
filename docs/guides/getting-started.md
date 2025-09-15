# Getting Started with BasicCli

## Prerequisites

### For Ruby Development
- Ruby 2.7+ (recommend 3.2+ for YJIT)
- Bundler (`gem install bundler`)

### For Rust Compilation
- Rust 1.70+ ([install from rustup.rs](https://rustup.rs/))
- Cargo (comes with Rust)

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/ai-ptd-dev/basiccli
cd basiccli
```

### 2. Install Ruby Dependencies
```bash
bundle install
```

### 3. Compile Rust Binary (Optional)
```bash
./bin/compile
```

## Project Structure

```
basiccli/
├── src/
│   ├── cli.rb              # Ruby CLI entry point
│   ├── cli.rs              # Rust CLI entry point (transpiled)
│   ├── commands/
│   │   ├── hello.rb        # Ruby command
│   │   ├── hello.rs        # Rust command (transpiled)
│   │   ├── version.rb
│   │   ├── version.rs
│   │   └── ...
│   └── utils/
│       ├── logger.rb       # Ruby utility
│       ├── logger.rs       # Rust utility (transpiled)
│       └── ...
├── spec/
│   ├── commands/
│   │   ├── hello_spec.rb   # Ruby tests
│   │   ├── hello_test.rs   # Rust tests
│   │   └── ...
│   └── spec_helper.rb
├── bin/
│   ├── basiccli-ruby       # Ruby executable
│   ├── basiccli-rust       # Rust executable
│   ├── compile             # Build Rust binary
│   ├── test               # Run Rust tests
│   ├── rspec              # Run Ruby tests
│   └── lint               # Lint both languages
└── docs/                   # Documentation
```

## Running the CLI

### Ruby Version (Development)
```bash
# Using the script
./bin/basiccli-ruby hello "World"

# Direct execution
bundle exec ruby src/cli.rb hello "World"
```

### Rust Version (Production)
```bash
# First compile
./bin/compile

# Then run
./bin/basiccli-rust hello "World"

# Or directly
./target/release/basiccli-rust hello "World"
```

## Available Commands

### Hello Command
```bash
# Basic greeting
./bin/basiccli-ruby hello "Alice"

# With options
./bin/basiccli-ruby hello "Bob" --uppercase --repeat 3
```

### Version Command
```bash
# Human-readable
./bin/basiccli-ruby version

# JSON output
./bin/basiccli-ruby version --json
```

### Benchmark Command
```bash
# Run benchmarks
./bin/basiccli-ruby benchmark 1000

# Output formats
./bin/basiccli-ruby benchmark 1000 --output json
./bin/basiccli-ruby benchmark 1000 --output csv

# Verbose mode
./bin/basiccli-ruby benchmark 1000 --verbose
```

### Process Command
```bash
# Process JSON file
./bin/basiccli-ruby process data.json

# With options
./bin/basiccli-ruby process data.json --pretty --stats
```

## Development Workflow

### 1. Write Ruby Code
Create your command in `src/commands/`:
```ruby
module BasicCli
  module Commands
    class MyCommand
      def initialize(options = {})
        @options = options
      end
      
      def execute
        puts "Hello from MyCommand!"
      end
    end
  end
end
```

### 2. Add to CLI
Register in `src/cli.rb`:
```ruby
desc "mycommand", "Description here"
def mycommand
  command = Commands::MyCommand.new(options)
  command.execute
end
```

### 3. Write Tests
Create `spec/commands/mycommand_spec.rb`:
```ruby
RSpec.describe BasicCli::Commands::MyCommand do
  it 'executes successfully' do
    command = described_class.new
    expect { command.execute }.to output(/Hello/).to_stdout
  end
end
```

### 4. Run Tests
```bash
./bin/rspec
```

### 5. Transpile to Rust
Manually create `src/commands/mycommand.rs`:
```rust
pub struct MyCommand {
    // fields
}

impl MyCommand {
    pub fn new() -> Self {
        Self {}
    }
    
    pub fn execute(&self) -> Result<()> {
        println!("Hello from MyCommand!");
        Ok(())
    }
}
```

### 6. Compile and Test
```bash
./bin/compile
./bin/test
```

## Helper Scripts

### `bin/compile`
Builds the Rust binary with optimizations:
```bash
./bin/compile
```

### `bin/test`
Runs Rust tests:
```bash
./bin/test
```

### `bin/rspec`
Runs Ruby tests:
```bash
./bin/rspec
```

### `bin/lint`
Lints and auto-fixes both Ruby and Rust:
```bash
./bin/lint
```

## Performance Comparison

Compare Ruby vs Rust performance:
```bash
# Ruby version
time ./bin/basiccli-ruby benchmark 1000

# Rust version
time ./bin/basiccli-rust benchmark 1000
```

## Next Steps

1. **Explore the code**: Look at existing commands for patterns
2. **Add your command**: Follow the development workflow
3. **Benchmark**: Compare Ruby vs Rust performance
4. **Optimize**: Profile and improve bottlenecks
5. **Deploy**: Use the Rust binary in production

## Tips

- Keep Ruby and Rust implementations functionally identical
- Use Ruby for rapid prototyping
- Transpile to Rust for production deployment
- Run both test suites to ensure parity
- Use the performance benchmarks to validate improvements