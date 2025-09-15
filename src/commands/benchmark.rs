use anyhow::Result;
use serde_json::json;
use std::collections::HashMap;
use std::io::Write;
use std::time::{Duration, Instant};
use tempfile::NamedTempFile;

pub struct BenchmarkCommand {
    iterations: usize,
    output_format: String,
    verbose: bool,
}

#[derive(Debug, Clone)]
struct BenchmarkResult {
    name: String,
    iterations: usize,
    total_time: Duration,
    avg_time: Duration,
    ops_per_sec: f64,
}

impl BenchmarkCommand {
    pub fn new(iterations: usize, output_format: String, verbose: bool) -> Self {
        Self {
            iterations,
            output_format,
            verbose,
        }
    }

    pub fn execute(&self) -> Result<()> {
        if self.verbose {
            println!("Running benchmarks with {} iterations...", self.iterations);
        }

        let results = self.run_benchmarks();

        match self.output_format.as_str() {
            "json" => self.output_json(&results),
            "csv" => self.output_csv(&results),
            _ => self.output_console(&results),
        }

        Ok(())
    }

    fn run_benchmarks(&self) -> Vec<BenchmarkResult> {
        vec![
            self.benchmark_string_manipulation(),
            self.benchmark_array_operations(),
            self.benchmark_file_io(),
            self.benchmark_json_parsing(),
            self.benchmark_hash_operations(),
        ]
    }

    fn benchmark_string_manipulation(&self) -> BenchmarkResult {
        let start = Instant::now();

        for i in 0..self.iterations {
            let mut s = format!("Hello World {}", i);
            s = s.to_uppercase();
            s = s.chars().rev().collect();
            s = s.replace(['a', 'e', 'i', 'o', 'u'], "*");
            let _: String = s
                .chars()
                .map(|c| c.to_string())
                .collect::<Vec<_>>()
                .join("-");
        }

        let duration = start.elapsed();

        BenchmarkResult {
            name: "String Manipulation".to_string(),
            iterations: self.iterations,
            total_time: duration,
            avg_time: duration / self.iterations as u32,
            ops_per_sec: self.iterations as f64 / duration.as_secs_f64(),
        }
    }

    fn benchmark_array_operations(&self) -> BenchmarkResult {
        let start = Instant::now();

        for _ in 0..self.iterations {
            let mut arr: Vec<i32> = (1..=100).collect();
            arr = arr.iter().map(|n| n * 2).collect();
            arr.retain(|n| n % 3 == 0);
            arr.sort_unstable();
            arr.reverse();
            let _: i32 = arr.iter().sum();
        }

        let duration = start.elapsed();

        BenchmarkResult {
            name: "Array Operations".to_string(),
            iterations: self.iterations,
            total_time: duration,
            avg_time: duration / self.iterations as u32,
            ops_per_sec: self.iterations as f64 / duration.as_secs_f64(),
        }
    }

    fn benchmark_file_io(&self) -> BenchmarkResult {
        let start = Instant::now();

        if let Ok(mut file) = NamedTempFile::new() {
            for i in 0..self.iterations {
                let content = format!("Line {}: {}\n", i, "x".repeat(100));
                let _ = file.write_all(content.as_bytes());
                let _ = file.flush();
            }
        }

        let duration = start.elapsed();

        BenchmarkResult {
            name: "File I/O".to_string(),
            iterations: self.iterations,
            total_time: duration,
            avg_time: duration / self.iterations as u32,
            ops_per_sec: self.iterations as f64 / duration.as_secs_f64(),
        }
    }

    fn benchmark_json_parsing(&self) -> BenchmarkResult {
        let sample_data = json!({
            "users": (1..=10).map(|i| {
                json!({
                    "id": i,
                    "name": format!("User {}", i),
                    "email": format!("user{}@example.com", i),
                    "metadata": {
                        "created_at": "2025-01-15T00:00:00Z",
                        "tags": ["ruby", "ptd", "cli", "benchmark"]
                    }
                })
            }).collect::<Vec<_>>()
        });

        let json_string = serde_json::to_string(&sample_data).unwrap();

        let start = Instant::now();

        for _ in 0..self.iterations {
            if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(&json_string) {
                let _ = serde_json::to_string(&parsed);
            }
        }

        let duration = start.elapsed();

        BenchmarkResult {
            name: "JSON Parsing".to_string(),
            iterations: self.iterations,
            total_time: duration,
            avg_time: duration / self.iterations as u32,
            ops_per_sec: self.iterations as f64 / duration.as_secs_f64(),
        }
    }

    fn benchmark_hash_operations(&self) -> BenchmarkResult {
        let start = Instant::now();

        for _ in 0..self.iterations {
            let mut map = HashMap::new();
            for i in 0..100 {
                map.insert(format!("key_{}", i), i * 2);
            }
            let mut keys: Vec<_> = map.keys().cloned().collect();
            keys.sort();
            let _: i32 = map.values().sum();
            map.insert("extra".to_string(), 999);
            let _: HashMap<_, _> = map.into_iter().filter(|(_, v)| *v > 50).collect();
        }

        let duration = start.elapsed();

        BenchmarkResult {
            name: "Hash Operations".to_string(),
            iterations: self.iterations,
            total_time: duration,
            avg_time: duration / self.iterations as u32,
            ops_per_sec: self.iterations as f64 / duration.as_secs_f64(),
        }
    }

    fn output_console(&self, results: &[BenchmarkResult]) {
        println!("\n{}", "=".repeat(60));
        println!("{:^60}", "BENCHMARK RESULTS");
        println!("{}", "=".repeat(60));

        for result in results {
            println!("\n{}:", result.name);
            println!("  Iterations:     {}", result.iterations);
            println!("  Total time:     {}", format_duration(result.total_time));
            println!("  Avg time/op:    {}", format_duration(result.avg_time));
            println!("  Ops/second:     {:.2}", result.ops_per_sec);
        }

        let total_time: Duration = results.iter().map(|r| r.total_time).sum();
        println!("\n{}", "=".repeat(60));
        println!("Total benchmark time: {}", format_duration(total_time));
        println!("{}", "=".repeat(60));
    }

    fn output_json(&self, results: &[BenchmarkResult]) {
        let output = json!({
            "timestamp": chrono::Utc::now().to_rfc3339(),
            "platform": std::env::consts::OS,
            "ruby_version": format!("Rust {}", env!("CARGO_PKG_RUST_VERSION")),
            "benchmarks": results.iter().map(|r| {
                json!({
                    "name": r.name,
                    "iterations": r.iterations,
                    "total_time_ms": r.total_time.as_millis(),
                    "avg_time_ms": r.avg_time.as_micros() as f64 / 1000.0,
                    "ops_per_second": r.ops_per_sec
                })
            }).collect::<Vec<_>>()
        });

        println!("{}", serde_json::to_string_pretty(&output).unwrap());
    }

    fn output_csv(&self, results: &[BenchmarkResult]) {
        println!("Benchmark,Iterations,Total Time (s),Avg Time (s),Ops/Second");
        for r in results {
            println!(
                "{},{},{:.6},{:.9},{:.2}",
                r.name,
                r.iterations,
                r.total_time.as_secs_f64(),
                r.avg_time.as_secs_f64(),
                r.ops_per_sec
            );
        }
    }
}

fn format_duration(d: Duration) -> String {
    if d.as_secs() > 0 {
        format!("{:.2} s", d.as_secs_f64())
    } else if d.as_millis() > 0 {
        format!("{:.2} ms", d.as_millis() as f64)
    } else {
        format!("{:.2} μs", d.as_micros() as f64)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_console_output() {
        let cmd = BenchmarkCommand::new(10, "console".to_string(), false);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_json_output() {
        let cmd = BenchmarkCommand::new(10, "json".to_string(), false);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_csv_output() {
        let cmd = BenchmarkCommand::new(10, "csv".to_string(), false);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_verbose_mode() {
        let cmd = BenchmarkCommand::new(10, "console".to_string(), true);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_benchmark_results_structure() {
        let cmd = BenchmarkCommand::new(10, "console".to_string(), false);
        let results = cmd.run_benchmarks();

        assert_eq!(results.len(), 5);
        for result in results {
            assert!(result.iterations == 10);
            assert!(result.ops_per_sec > 0.0);
            assert!(result.total_time > Duration::from_secs(0));
        }
    }
}
