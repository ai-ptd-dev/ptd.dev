use anyhow::Result;
use clap::{Parser, Subcommand};
use std::path::PathBuf;

mod commands {
    pub mod benchmark;
    pub mod hello;
    pub mod version;
}

mod utils {
    pub mod file_handler;
    pub mod logger;
}

use commands::{benchmark::BenchmarkCommand, hello::HelloCommand, version::VersionCommand};
use utils::logger::Logger;

#[derive(Parser)]
#[command(name = "basiccli-rust")]
#[command(author, version, about = "BasicCli - High Performance CLI (Rust Version)", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Greet someone with a personalized message
    Hello {
        /// Name of the person to greet
        name: String,

        /// Print greeting in uppercase
        #[arg(short, long)]
        uppercase: bool,

        /// Repeat the greeting N times
        #[arg(short, long, default_value_t = 1)]
        repeat: usize,
    },

    /// Display version information
    Version {
        /// Output version info as JSON
        #[arg(long)]
        json: bool,
    },

    /// Run performance benchmarks
    Benchmark {
        /// Number of iterations
        #[arg(default_value_t = 1000)]
        iterations: usize,

        /// Output format: console, json, or csv
        #[arg(short, long, default_value = "console")]
        output: String,

        /// Show detailed benchmark information
        #[arg(short, long)]
        verbose: bool,
    },

    /// Process a JSON file and demonstrate file I/O
    Process {
        /// File to process
        file: PathBuf,

        /// Pretty print JSON output
        #[arg(short, long)]
        pretty: bool,

        /// Show processing statistics
        #[arg(short, long)]
        stats: bool,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Hello {
            name,
            uppercase,
            repeat,
        } => {
            let command = HelloCommand::new(name, uppercase, repeat);
            command.execute()?;
        }
        Commands::Version { json } => {
            let command = VersionCommand::new(json);
            command.execute()?;
        }
        Commands::Benchmark {
            iterations,
            output,
            verbose,
        } => {
            let command = BenchmarkCommand::new(iterations, output, verbose);
            command.execute()?;
        }
        Commands::Process {
            file,
            pretty,
            stats,
        } => {
            process_file(file, pretty, stats)?;
        }
    }

    Ok(())
}

fn process_file(file: PathBuf, pretty: bool, stats: bool) -> Result<()> {
    let logger = Logger::new(if stats {
        utils::logger::LogLevel::Debug
    } else {
        utils::logger::LogLevel::Info
    });

    logger.info(&format!("Processing file: {}", file.display()));

    if !file.exists() {
        logger.error(&format!("File not found: {}", file.display()));
        std::process::exit(1);
    }

    let content = std::fs::read_to_string(&file)?;
    let data: serde_json::Value = serde_json::from_str(&content).map_err(|e| {
        logger.error(&format!("Invalid JSON: {}", e));
        e
    })?;

    if let Some(obj) = data.as_object() {
        logger.info(&format!("Successfully parsed JSON with {} keys", obj.len()));
    }

    if pretty {
        println!("{}", serde_json::to_string_pretty(&data)?);
    } else {
        println!("{}", serde_json::to_string(&data)?);
    }

    if stats {
        let metadata = std::fs::metadata(&file)?;
        logger.info(&format!("File size: {} bytes", metadata.len()));
        logger.info("Processing complete");
    }

    Ok(())
}
