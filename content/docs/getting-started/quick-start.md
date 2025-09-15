---
title: "Quick Start Guide"
description: "Get up and running with PTD in minutes"
order: 1
---

# Quick Start Guide

Welcome to PTD! This guide will get you up and running with Polyglot Transpilation Development in just a few minutes.

## Prerequisites

Before you begin, make sure you have:

- Ruby 2.7+ installed
- Rust 1.70+ installed (for running transpiled code)
- Git for version control
- OpenCode CLI (for AI transpilation)

## Installation

### 1. Clone the PTD Boilerplate

```bash
git clone https://github.com/sebyx07/ptd-ruby-cli.git my-project
cd my-project
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Verify Installation

```bash
# Test Ruby version
./bin/basiccli-ruby hello World

# Test Rust version (if pre-built)
./bin/basiccli-rust hello World
```

## Your First PTD Project

### 1. Create a New Command

Create a new Ruby command in `src/commands/`:

```ruby
# src/commands/greet.rb
module BasicCli
  module Commands
    class Greet
      def initialize(name, options = {})
        @name = name
        @options = options
      end

      def execute
        greeting = build_greeting
        puts greeting
      end

      private

      def build_greeting
        base = "Hello, #{@name}!"
        @options[:enthusiastic] ? "#{base} 🎉" : base
      end
    end
  end
end
```

### 2. Add the Command to CLI

Update `src/server.rb` (or your main CLI file):

```ruby
desc 'greet NAME', 'Greet someone personally'
option :enthusiastic, type: :boolean, desc: 'Add enthusiasm'
def greet(name)
  command = Commands::Greet.new(name, options)
  command.execute
end
```

### 3. Test Your Ruby Implementation

```bash
./bin/basiccli-ruby greet Alice
./bin/basiccli-ruby greet Alice --enthusiastic
```

### 4. Transpile to Rust

Use OpenCode to automatically generate the Rust version:

```bash
opencode
> /transpile
```

The AI will create `src/commands/greet.rs` with equivalent functionality.

### 5. Build and Test Rust Version

```bash
./bin/compile
./bin/basiccli-rust greet Alice --enthusiastic
```

## Performance Comparison

Compare the startup times:

```bash
# Ruby version
time ./bin/basiccli-ruby greet Alice

# Rust version  
time ./bin/basiccli-rust greet Alice
```

You should see the Rust version start ~250x faster!

## Next Steps

- [Learn about the PTD paradigm](/docs/guides/ptd-concepts)
- [Explore advanced features](/docs/guides/advanced-usage)
- [See real-world examples](/docs/reference/examples)
- [Contribute to PTD](/docs/guides/contributing)

## Need Help?

- Check the [FAQ](/contact#faq)
- Browse the [documentation](/docs)
- [Open an issue](https://github.com/sebyx07) on GitHub