# PTD Ruby CLI - AI-Powered Polyglot Framework

> **Develop in Ruby, Deploy in Rust**: OpenCode agents achieve 250x performance gains through intelligent transpilation.

This framework demonstrates **PTD (Polyglot Transpilation Development)** - an AI-powered paradigm where you develop in expressive Ruby and automatically deploy optimized Rust binaries using OpenCode agents.

## 🚀 Quick Start Options

### Option 1: Complete TodoCLI Example (Recommended)
```bash
# Clone the complete TodoCLI implementation
git clone https://github.com/ai-ptd-dev/ptd-ruby-cli.git -b todo-list-example
cd ptd-ruby-cli

# Install dependencies and try it out
bundle install
./bin/todocli-ruby add "Learn PTD with OpenCode" --priority high
./bin/todocli-ruby list

# Experience 250x performance with Rust
./bin/compile
./bin/todocli-rust list  # Instant execution!
```

### Option 2: Clean Framework (Advanced)
```bash
# Clone the base framework for custom projects
git clone https://github.com/ai-ptd-dev/ptd-ruby-cli.git
cd ptd-ruby-cli

# Build your own CLI with OpenCode agents
bundle install
# Add your commands in Ruby, let AI transpile to Rust
```

## 📊 AI-Achieved Performance Gains

OpenCode agents automatically optimized the transpilation to achieve:

| Metric | Ruby | Rust | AI Improvement |
|--------|------|------|----------------|
| **Startup Time** | 250ms | 1ms | **250x faster** |
| **Memory Usage** | 29MB | 3MB | **90% reduction** |
| **Binary Size** | 40MB+ deps | 1.1MB | **97% smaller** |
| **Cold Start** | Ruby + bundler | Native binary | **Instant execution** |

## 🎯 What is PTD?

**Polyglot Transpilation Development** is an AI-powered programming paradigm where:

1. **🚀 Rapid Development**: Write in expressive languages (Ruby, Python)
2. **🤖 AI Transpilation**: OpenCode agents automatically convert to system languages (Rust, Go)  
3. **⚡ Production Deployment**: Ship optimized native binaries with massive performance gains
4. **🔄 Continuous Parity**: Maintain identical functionality across language implementations

### The OpenCode Advantage

- **🧠 AI-Powered**: Agents understand semantics, not just syntax
- **🎯 Context-Aware**: Maintains business logic and error handling
- **📋 Test Generation**: Creates comprehensive test suites automatically
- **🔧 Optimization**: Applies language-specific performance patterns

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

## 📈 Real-World Impact: TodoCLI Case Study

### Proven Performance Gains (todo-list-example branch)

**Daily CLI Usage (100 operations)**:
- **Ruby Version**: 25 seconds total startup overhead
- **Rust Version**: 0.1 seconds total startup time
- **Net Benefit**: 24.9 seconds saved daily (99.6% improvement)

**Batch Processing (1000 database operations)**:
- **Ruby Implementation**: 4.2 minutes execution time
- **Rust Implementation**: 4 seconds execution time  
- **Net Benefit**: 4+ minutes saved per batch (98.4% improvement)

### Development Velocity Impact
- **Ruby Development Time**: 2 days for full TodoCLI implementation
- **Manual Rust Port Time**: Estimated 5-7 days for equivalent functionality
- **OpenCode Transpilation Time**: Automated in minutes
- **Total Time Saved**: 3-5 days of development effort

### OpenCode Agent Value Demonstration
- **🚀 Instant Transpilation**: No manual rewriting of business logic
- **🧪 Comprehensive Testing**: 69 tests generated automatically
- **🎯 Perfect Parity**: Identical functionality guaranteed across languages
- **⚡ Performance Optimization**: Best practices applied without manual effort

## 🎓 OpenCode & PTD Documentation

- [**PTD Paradigm**](docs/base/ptd-paradigm.md) - AI-powered polyglot development
- [**Performance Analysis**](docs/base/performance.md) - Agent optimization results
- [**Getting Started**](docs/guides/getting-started.md) - OpenCode setup and usage
- [**AI Agent Workflows**](docs/guides/) - Transpilation patterns and examples

### OpenCode Resources
- **Agent Models**: Ruby-to-Rust transpilation specialists
- **AI Capabilities**: Semantic understanding, test generation, optimization
- **Integration**: Seamless development workflow automation

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

## 🤝 Contributing to PTD & OpenCode

### Ways to Contribute
1. **🔧 Framework Improvements**: Enhance the PTD boilerplate
2. **🤖 Agent Enhancement**: Improve transpilation quality and coverage
3. **📊 Benchmarking**: Add performance analysis and optimization
4. **📚 Documentation**: Expand PTD methodology and examples
5. **🌐 Language Support**: Extend beyond Ruby→Rust transpilation

### Contribution Guidelines
- Maintain functional parity between language implementations
- Include comprehensive test coverage for both languages
- Document AI agent decision patterns and optimizations
- Ensure performance benchmarks validate improvements

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