---
description: Convert BasicCli boilerplate to your own CLI project
agent: general
model: anthropic/claude-sonnet-4
---

I'll help you convert the BasicCli boilerplate into your own CLI project. First, I need to gather some information about your project.

Please answer these questions:

1. **Project Name**: What is your CLI project name? (e.g., "MyCoolTool", "DataProcessor", "DevHelper")
   - This will be used as the main module name and display name

2. **Description**: What does your CLI do? (one line description)
   - This will be used in documentation and package descriptions

3. **Primary Purpose**: What is the main functionality? (e.g., "file processing", "API interactions", "development tools", "data analysis")
   - This helps me understand what kind of commands you might need

4. **Target Users**: Who will use this CLI? (e.g., "developers", "data scientists", "system administrators", "general users")
   - This helps tailor the examples and documentation

Based on your answers, I will:
- Rename all BasicCli references to your project name
- Update module names, binary names, and constants
- Modify README.md with your project information
- Update Cargo.toml and Gemfile with your project details
- Rename the binary executables
- Create an initial command structure based on your use case
- Provide guidance on next steps for implementing your specific features

The conversion will maintain the PTD (Polyglot Transpilation Development) paradigm, allowing you to develop in Ruby and deploy optimized Rust binaries.