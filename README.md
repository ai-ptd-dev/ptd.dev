# BasicCli - Polyglot CLI Framework

> **A revolutionary boilerplate**: Write in Ruby, Deploy in Rust. Get 50x faster startup, 2-3x faster execution.

BasicCli demonstrates the **PTD (Polyglot Transpilation Development)** paradigm - develop in expressive Ruby, deploy optimized Rust binaries.

## 🚀 Quick Start

```bash
# Clone the boilerplate
git clone https://github.com/ai-ptd-dev/basiccli
cd basiccli

# Install Ruby dependencies
bundle install

# Run Ruby version (development)
./bin/basiccli-ruby hello "World"

# Compile to Rust (production)
./bin/compile

# Run Rust version (50x faster!)
./bin/basiccli-rust hello "World"
```

## 📊 Performance Gains

| Metric | Ruby | Rust | Improvement |
|--------|------|------|-------------|
| **Startup Time** | 258ms | 5ms | **51.6x faster** |
| **Memory Usage** | 48MB | 2.8MB | **94% less** |
| **Benchmarks** | 91ms | 40ms | **2.3x faster** |
| **Binary Size** | 40MB+ deps | 1.1MB standalone | **97% smaller** |

## 🎯 What is PTD?

**Polyglot Transpilation Development** is a new programming paradigm where you:
1. **Develop** in high-level languages (Ruby, Python)
2. **Transpile** to system languages (Rust, Go)
3. **Deploy** optimized native binaries

[Learn more about PTD →](docs/base/ptd-paradigm.md)

## 📁 Project Structure

```
basiccli/
├── src/
│   ├── cli.rb              # Ruby entry point
│   ├── cli.rs              # Rust entry point (transpiled)
│   ├── commands/
│   │   ├── hello.rb        # Ruby implementation
│   │   ├── hello.rs        # Rust implementation (side-by-side!)
│   │   └── ...
│   └── utils/
│       ├── logger.rb       # Ruby utility
│       ├── logger.rs       # Rust utility
│       └── ...
├── spec/
│   ├── commands/
│   │   ├── hello_spec.rb   # Ruby tests
│   │   ├── hello_test.rs   # Rust tests (side-by-side!)
│   │   └── ...
├── bin/
│   ├── basiccli-ruby       # Ruby runner
│   ├── basiccli-rust       # Rust runner
│   ├── compile            # Build Rust binary
│   ├── test              # Run Rust tests
│   ├── rspec             # Run Ruby tests
│   └── lint              # Lint both languages
└── docs/
    ├── base/             # Core concepts
    ├── guides/           # How-to guides
    └── reference/        # API reference
```

## 🛠 Features

### Commands Included
- **hello** - Greeting with time-based messages
- **version** - Version info (text/JSON)
- **benchmark** - Performance testing suite
- **process** - JSON file processing

### Utilities
- **Logger** - Colored output, progress bars, timing
- **FileHandler** - JSON/YAML/CSV support, atomic writes

### Developer Tools
- `./bin/compile` - Build optimized Rust binary
- `./bin/test` - Run Rust test suite
- `./bin/rspec` - Run Ruby test suite
- `./bin/lint` - Auto-fix code style issues

## 💻 Development Workflow

### 1. Create Ruby Command
```ruby
# src/commands/mycommand.rb
module BasicCli
  module Commands
    class MyCommand
      def execute
        puts "Hello from Ruby!"
      end
    end
  end
end
```

### 2. Write Tests
```ruby
# spec/commands/mycommand_spec.rb
RSpec.describe BasicCli::Commands::MyCommand do
  it 'works' do
    expect { described_class.new.execute }
      .to output(/Hello/).to_stdout
  end
end
```

### 3. Transpile to Rust
```rust
// src/commands/mycommand.rs
pub struct MyCommand;

impl MyCommand {
    pub fn execute(&self) -> Result<()> {
        println!("Hello from Rust!");
        Ok(())
    }
}
```

### 4. Compile & Deploy
```bash
./bin/compile
./bin/basiccli-rust mycommand  # Instant execution!
```

## 📈 Real-World Impact

For a CLI tool run 100 times daily:
- **Ruby**: 25.8 seconds total runtime
- **Rust**: 0.5 seconds total runtime
- **Time saved**: 25.3 seconds/day (98% reduction)

In scripts processing 1000 files:
- **Ruby**: 4.3 minutes
- **Rust**: 5 seconds
- **Time saved**: 4.2 minutes (98% reduction)

## 🎓 Documentation

- [**Getting Started**](docs/guides/getting-started.md) - Setup and first steps
- [**PTD Paradigm**](docs/base/ptd-paradigm.md) - Understanding the methodology
- [**Performance Analysis**](docs/base/performance.md) - Detailed benchmarks
- [**Examples**](docs/guides/) - More guides and patterns

## 🔧 Use This Boilerplate

1. **Fork this repository**
2. **Rename** BasicCli to your project name
3. **Add commands** following the pattern
4. **Write tests** for both Ruby and Rust
5. **Deploy** the Rust binary

### Customization Example

```bash
# Fork and rename
git clone https://github.com/yourusername/mycli
cd mycli

# Add your command
vim src/commands/deploy.rb
vim src/commands/deploy.rs

# Test both versions
./bin/rspec
./bin/test

# Ship it!
./bin/compile
cp target/release/mycli-rust /usr/local/bin/mycli
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Ensure both Ruby and Rust tests pass
4. Maintain functional parity between languages
5. Submit a pull request

## 📄 License

MIT License - Use freely in your projects

## 🌟 Why BasicCli?

- **Best of Both Worlds**: Ruby's expressiveness, Rust's performance
- **Side-by-Side Code**: See Ruby and Rust implementations together
- **Production Ready**: Full test suites, linting, documentation
- **Real Performance**: Not theoretical - actual 50x startup improvement
- **Developer Friendly**: Helper scripts for common tasks

## 🚦 Status

- ✅ Ruby implementation complete
- ✅ Rust transpilation complete  
- ✅ Test suites passing
- ✅ Documentation complete
- ✅ Performance validated

## 🔗 Links

- [PTD Methodology](https://github.com/ai-ptd-dev)
- [Performance Report](docs/base/performance.md)
- [Getting Started Guide](docs/guides/getting-started.md)

---

**Ready to build fast CLIs?** Fork BasicCli and experience the PTD paradigm! 🚀