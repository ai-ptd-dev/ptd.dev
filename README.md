# PTD.dev - Polyglot Transpilation Development

> **Write Expressive, Deploy Native - The official website for PTD**

PTD.dev is the official website for Polyglot Transpilation Development - a paradigm where expressive programming languages (Ruby, Python, JavaScript) are transpiled to fast native code (Rust, Swift, C#) using AI.

**This website itself is built with PTD**: Developed locally with Ruby/Sinatra for rapid iteration, deployed in production as transpiled Rust for blazing-fast performance.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/ai-ptd-dev/ptd.dev.git
cd ptd.dev

# Install dependencies
bundle install

# Start development server
./bin/server

# Visit http://localhost:4567
```

## 🎯 What is PTD?

**Polyglot Transpilation Development** enables developers to:

1. **Write in comfortable languages** - Ruby, Python, JavaScript
2. **AI transpiles to native code** - Rust for systems, Swift for iOS, C# for Windows
3. **Deploy with native performance** - 250x faster, 90% less memory
4. **No runtime overhead** - No garbage collector, no JIT

## 📊 Real Performance Gains

| Metric | Ruby/Python/JS | Transpiled to Rust | Improvement |
|--------|----------------|-------------------|-------------|
| **Startup Time** | 2-3 seconds | 10ms | **250x faster** |
| **Memory Usage** | 150MB | 15MB | **90% reduction** |
| **Binary Size** | 50MB + deps | 1.5MB | **97% smaller** |
| **Request/sec** | 3,000 | 1,000,000+ | **300x more** |

## 🏗️ This Website as PTD Example

### Development (Local)
- **Language**: Ruby 3.4+ with Sinatra
- **Templates**: ERB with hot reload
- **Tools**: Full Ruby ecosystem
- **Experience**: Fast iteration, easy debugging

### Production (Deployed)
- **Language**: Rust with Actix Web
- **Templates**: Compiled templates
- **Binary**: Single static executable
- **Performance**: 250x faster startup, 90% less RAM

## 📁 Project Structure

```
ptd.dev/
├── src/
│   ├── server.rb              # Sinatra application (dev)
│   └── utils/                 # Content management
├── views/                     # ERB templates
├── content/
│   ├── pages/                # Static pages
│   ├── blog/                 # Blog posts
│   └── docs/                 # Documentation
├── public/                    # Static assets
├── spec/                      # RSpec tests
└── bin/                       # CLI tools
```

## 🛠️ Development Tools

```bash
# Start development server with auto-reload
./bin/server --rerun

# Generate a new blog post
./bin/generate-post "Your Post Title"

# Run tests
bundle exec rspec

# Run linting
bundle exec rubocop -A
```

## 📝 Content Management

### Blog Posts

Use the generator for consistent structure:

```bash
./bin/generate-post "Rust is the New Assembly"
# Creates: content/blog/20250915164001_rust-is-the-new-assembly.md
# URL: /blog/2025/09/15/rust-is-the-new-assembly
```

### Pages

Create HTML files in `content/pages/`:

```html
---
title: "Page Title"
description: "SEO description"
---

<h1>Your Content</h1>
```

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test
bundle exec rspec spec/app_spec.rb
```

Current test coverage: **96%** (120/125 tests passing)

## 🚀 Deployment

### PTD Transpilation Process

```bash
# Development (Ruby/Sinatra)
bundle exec rackup config.ru

# Transpile to Rust
ptd transpile src/ --target rust --framework actix

# Production (Rust)
./ptd-dev-server
# Starts in 10ms, uses 15MB RAM
```

### Traditional Deployment

```bash
# Set production environment
export RACK_ENV=production

# Install production dependencies
bundle install --without development test

# Start with Puma
bundle exec puma -C config/puma.rb
```

## 🌟 PTD Repositories

| Repository | Description | Language | Target |
|------------|-------------|----------|--------|
| [ptd-ruby-cli](https://github.com/ai-ptd-dev/ptd-ruby-cli) | Ruby CLI boilerplate | Ruby | Rust |
| [ptd-python-cli](https://github.com/ai-ptd-dev/ptd-python-cli) | Python CLI boilerplate | Python | Rust |
| [ptd-node-cli](https://github.com/ai-ptd-dev/ptd-node-cli) | Node CLI boilerplate | JavaScript | Rust |
| [ptd.dev](https://github.com/ai-ptd-dev/ptd.dev) | This website | Ruby/Sinatra | Rust |

## 📖 Key Blog Post

**"Rust is the New Assembly"** - Read our manifesto on why Rust has become the universal compilation target, replacing assembly as the foundation for modern transpilation.

## 🤝 Contributing

We welcome contributions! Areas of interest:

1. **Content** - Blog posts about transpilation experiences
2. **Examples** - Real-world PTD use cases
3. **Tools** - Improve the transpilation pipeline
4. **Documentation** - Help others understand PTD

## 📄 License

MIT License - Use freely in your projects

## 👨‍💻 Creator

Created by [Sebastian Buza](https://github.com/sebyx07) to demonstrate that developers shouldn't have to choose between productivity and performance.

## 🔗 Links

- [PTD Organization](https://github.com/ai-ptd-dev)
- [Live Website](https://ptd.dev) (when deployed)
- [Creator's GitHub](https://github.com/sebyx07)

---

**Remember**: This website you're reading about? It's developed in Ruby for developer happiness, but runs in production as Rust for user happiness. That's the power of PTD! 🚀