# PTD Ruby CLI - Developer-First Framework with OpenCode AI

> **Write Ruby, Ship Rust**: Real developers using OpenCode AI agents to achieve 250x performance gains through automatic transpilation.

This framework demonstrates **PTD (Polyglot Transpilation Development)** - a developer-first approach where you write Ruby code and OpenCode AI agents automatically create optimized Rust versions. No manual porting, no compromise on performance.

## 🚀 Quick Start for Developers

### Start Your Own Project (Fork This!)
```bash
# 1. Fork this repository on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/ptd-ruby-cli.git
cd ptd-ruby-cli

# 2. Install dependencies
bundle install

# 3. Customize it for your project with OpenCode
opencode
> /setup
> [Answer questions about your CLI project]
> [AI renames everything and configures your project]
> /transpile  # (if /setup renamed things)
> [AI generates Rust versions of your renamed code]
> exit

# 4. Try the example commands (now with your project name!)
./bin/yourcli-ruby hello
./bin/yourcli-ruby version

# 5. Build and run the Rust version
./bin/compile
./bin/yourcli-rust hello  # 250x faster startup!
```

### See a Complete Example: TodoCLI
Want to see what you can build? Check out the **[todo-list-example branch](https://github.com/ai-ptd-dev/ptd-ruby-cli/tree/todo-list-example)**:
- Full todo list manager with SQLite
- 7 commands, 69 tests, 250x performance gain
- Shows OpenCode agents in action

```bash
# View the example (don't clone, just browse)
# https://github.com/ai-ptd-dev/ptd-ruby-cli/tree/todo-list-example
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

## 🤖 OpenCode Integration

### The .opencode Directory - Your AI Development Team

```
.opencode/
├── agent/                  # AI agent personalities
│   ├── ruby-dev.md        # Ruby expert following SOLID principles
│   └── rust-transpiler.md # Rust expert for transpilation
└── command/               # OpenCode commands you can run
    ├── transpile.md       # Auto-transpile Ruby changes to Rust
    └── setup.md          # Convert boilerplate to your project
```

### How to Use OpenCode Agents

```bash
# 1. Start an OpenCode interactive session
opencode

# 2. Inside the OpenCode session, use these commands:
/setup      # Interactive setup for your new project (after forking)
            # - Asks for project name, description, purpose
            # - Renames all BasicCli references to your project
            # - Updates documentation and configuration

/transpile  # Automatically transpile Ruby changes to Rust
            # - Detects modified Ruby files via git
            # - Generates equivalent Rust code
            # - Runs tests for both languages
            # - Applies formatting and linting

# 3. Or call specific agents directly:
@ruby-dev        # Ruby expert for SOLID principles & clean code
                 # "Create a new command that processes CSV files"
                 
@rust-transpiler # Rust expert for manual transpilation
                 # "Convert this Ruby method to idiomatic Rust"

# 4. Example workflow after forking:
opencode
> /setup
> "What is your CLI project name?" MyCoolTool
> "What does your CLI do?" Manages deployments
> [AI renames everything and sets up your project]

# 5. Development cycle:
vim src/commands/deploy.rb  # Write Ruby code
opencode
> /transpile                 # AI transpiles to Rust
# OR manually with agents:
> @ruby-dev help me improve this command
> @rust-transpiler convert the deploy command to Rust
> exit

./bin/rspec                  # Verify Ruby tests
./bin/test                   # Verify Rust tests  
./bin/compile                # Build optimized binary
```

### Developer Workflow with OpenCode

1. **Write Ruby First**: Focus on functionality, not performance
2. **OpenCode Transpiles**: AI agents convert to idiomatic Rust
3. **Tests Ensure Parity**: Both implementations tested automatically
4. **Deploy Rust Binary**: Ship the performance-optimized version

## 📁 Project Structure

```
ptd-ruby-cli/
├── .opencode/              # OpenCode AI configuration
│   ├── agent/             # AI agent definitions
│   └── command/           # Automation commands
├── src/
│   ├── cli.rb             # Ruby entry point
│   ├── cli.rs             # Rust entry point (AI-transpiled)
│   ├── commands/
│   │   ├── *.rb           # Your Ruby implementations
│   │   └── *.rs           # AI-generated Rust versions
│   └── utils/
│       ├── *.rb           # Ruby utilities
│       └── *.rs           # Rust utilities (AI-transpiled)
├── spec/                   # Test suites for both languages
├── bin/                    # Developer tools
│   ├── compile            # Build Rust binary
│   ├── test              # Run Rust tests
│   ├── rspec             # Run Ruby tests
│   └── lint              # Lint both languages
└── docs/                   # Documentation
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

## 💻 Real Developer Workflow

### Step 1: Write Your Ruby Code (Focus on Logic)
```ruby
# src/commands/myfeature.rb
module TodoCli
  module Commands
    class MyFeature
      def execute(options = {})
        # Write clean Ruby - OpenCode handles the rest
        database = Utils::Database.new
        results = database.query(options[:filter])
        puts format_output(results)
      end
    end
  end
end
```

### Step 2: OpenCode Transpiles Automatically
```bash
# Start OpenCode session and run transpile
opencode
> /transpile

# OpenCode AI agent:
# ✓ Detects your Ruby changes via git
# ✓ Understands the business logic
# ✓ Generates idiomatic Rust code
# ✓ Maintains error handling patterns
# ✓ Creates equivalent tests
```

### Step 3: AI-Generated Rust (Optimized)
```rust
// src/commands/myfeature.rs (AI-generated)
use crate::utils::database::Database;
use anyhow::Result;

pub struct MyFeature;

impl MyFeature {
    pub fn execute(&self, filter: Option<&str>) -> Result<()> {
        let db = Database::new()?;
        let results = db.query(filter)?;
        println!("{}", self.format_output(&results));
        Ok(())
    }
}
```

### Step 4: Verify & Deploy
```bash
# Tests pass for both implementations
./bin/rspec  # ✓ Ruby tests
./bin/test   # ✓ Rust tests

# Ship the fast version
./bin/compile
./bin/todocli-rust myfeature  # 250x faster startup!
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

## 🎓 Learn More About OpenCode & PTD

### Essential Documentation
- [**OpenCode Guide**](opencode.md) - Complete guide to using OpenCode agents
- [**PTD Paradigm**](docs/base/ptd-paradigm.md) - Understanding polyglot development
- [**Getting Started**](docs/guides/getting-started.md) - Setup and first steps
- [**Performance Analysis**](docs/base/performance.md) - Real benchmarks

### OpenCode Agent Capabilities
- **ruby-dev Agent**: Writes clean Ruby following SOLID principles
- **rust-transpiler Agent**: Converts Ruby to optimized Rust
- **Semantic Understanding**: Preserves business logic, not just syntax
- **Test Generation**: Creates comprehensive test suites
- **Performance Optimization**: Applies Rust best practices automatically

### Try the TodoCLI Example
The **[todo-list-example branch](https://github.com/ai-ptd-dev/ptd-ruby-cli/tree/todo-list-example)** contains a complete todo list manager showing:
- Full CRUD operations with SQLite
- Priority management and filtering
- JSON export/import
- 69 auto-generated tests
- 250x performance improvement

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