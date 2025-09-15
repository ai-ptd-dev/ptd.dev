# Agent Instructions for PTD Ruby CLI

## Build/Test/Lint Commands
- **Ruby tests**: `bundle exec rspec` or `./bin/rspec`
- **Ruby single test**: `bundle exec rspec path/to/spec.rb:LINE` or `bundle exec rspec -e "test description"`
- **Rust tests**: `cargo test` or `./bin/test`
- **Rust single test**: `cargo test test_name` or `cargo test --test test_file_name`
- **Lint both**: `./bin/lint` (auto-fixes Ruby with Rubocop -A, Rust with rustfmt/clippy)
- **Compile Rust**: `./bin/compile` or `cargo build --release`

## Code Style Guidelines
**Ruby**: Single quotes for strings, snake_case methods/vars, CamelCase classes, 120 char lines, no frozen string comments
**Rust**: Use Result<T,E> for errors, prefer &str over String, implement Display/Debug traits, use anyhow for error handling
**Imports**: Ruby uses require_relative for internal deps; Rust uses anyhow::Result, chrono for time, colored for output
**Testing**: Ruby RSpec with descriptive contexts; Rust #[test] functions in same file or tests/ directory
**Naming**: Commands in src/commands/, utilities in src/utils/, maintain Ruby/Rust file parity (e.g., hello.rb/hello.rs)
**Error Handling**: Ruby returns Result objects with success/message; Rust uses Result<(), anyhow::Error>
**Project Structure**: Polyglot development - write Ruby first, transpile to Rust maintaining same API and behavior

## PTD Paradigm
Develop features in Ruby for rapid iteration, then transpile to Rust for 50x faster startup and deployment.

## Development Policy
**IMPORTANT**: All new features and modifications should be implemented in Ruby code only. Do not write or modify Rust code directly. The Rust code will be generated through transpilation from the Ruby implementation.