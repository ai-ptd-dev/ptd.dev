---
description: Automatically transpile changed Ruby files to Rust
agent: rust-transpiler
model: anthropic/claude-sonnet-4
---

Automatically detect changed Ruby files and transpile them to Rust implementations.

## Git Status
!`git status --porcelain`

## Current Diff
!`git diff`

## Instructions:

1. **Detect Changes**: Look at the git status output above to identify modified Ruby files (.rb)
2. **Analyze Changes**: Review the git diff to understand what changed in each Ruby file
3. **Transpile to Rust**: For each changed Ruby file:
   - Find the corresponding Rust file (e.g., src/commands/hello.rb → src/commands/hello.rs)
   - Apply the equivalent changes to the Rust implementation
   - Ensure the Rust code follows idiomatic patterns and matches the Ruby functionality exactly
   - Handle any new error cases or edge cases introduced

4. **Test the Changes**:
   - Run the Rust tests: `cargo test`
   - Run the Ruby tests: `bundle exec rspec`
   - Ensure all tests pass

5. **Lint and Format**:
   - Run Rust linter: `cargo clippy`
   - Run Rust formatter: `cargo fmt`
   - Fix any issues found

6. **Verification**:
   - Build the Rust binary: `cargo build --release`
   - Compare outputs between Ruby and Rust implementations for consistency

## Project Structure:
- Ruby files: src/**/*.rb
- Rust files: src/**/*.rs
- Ruby tests: spec/**/*_spec.rb
- Rust tests: integrated into .rs files or in spec/**/*_test.rs

## Important:
- Preserve the exact behavior and output formatting
- Match error messages and exit codes
- Ensure memory safety in Rust implementations
- Use the same algorithms and logic flow