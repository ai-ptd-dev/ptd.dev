use chrono::Local;
use colored::*;
use indicatif::{ProgressBar, ProgressStyle};
use std::io::Write;
use std::sync::Mutex;
use std::time::{Duration, Instant};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
#[allow(dead_code)]
pub enum LogLevel {
    Debug = 0,
    Info = 1,
    Warn = 2,
    Error = 3,
    Fatal = 4,
}

pub struct Logger {
    level: LogLevel,
    use_colors: bool,
    output: Mutex<Box<dyn Write + Send>>,
}

#[allow(dead_code)]
impl Logger {
    pub fn new(level: LogLevel) -> Self {
        Self {
            level,
            use_colors: atty::is(atty::Stream::Stdout),
            output: Mutex::new(Box::new(std::io::stdout())),
        }
    }

    pub fn new_with_options(level: LogLevel, use_colors: bool) -> Self {
        Self {
            level,
            use_colors,
            output: Mutex::new(Box::new(std::io::stdout())),
        }
    }

    pub fn debug(&self, message: &str) {
        self.log(LogLevel::Debug, message);
    }

    pub fn info(&self, message: &str) {
        self.log(LogLevel::Info, message);
    }

    pub fn warn(&self, message: &str) {
        self.log(LogLevel::Warn, message);
    }

    pub fn error(&self, message: &str) {
        self.log(LogLevel::Error, message);
    }

    pub fn fatal(&self, message: &str) {
        self.log(LogLevel::Fatal, message);
    }

    fn log(&self, severity: LogLevel, message: &str) {
        if severity < self.level {
            return;
        }

        let timestamp = Local::now().format("%Y-%m-%dT%H:%M:%S%.3f");
        let severity_str = format!("{:?}", severity).to_uppercase();

        let formatted = if self.use_colors {
            let colored_severity = match severity {
                LogLevel::Debug => severity_str.cyan(),
                LogLevel::Info => severity_str.green(),
                LogLevel::Warn => severity_str.yellow(),
                LogLevel::Error => severity_str.red(),
                LogLevel::Fatal => severity_str.magenta(),
            };
            format!("[{}] {} | {}", timestamp, colored_severity, message)
        } else {
            format!("[{}] {:5} | {}", timestamp, severity_str, message)
        };

        let mut output = self.output.lock().unwrap();
        writeln!(output, "{}", formatted).unwrap();
    }

    pub fn with_timing<F, R>(&self, message: &str, f: F) -> R
    where
        F: FnOnce() -> R,
    {
        let start = Instant::now();
        self.info(&format!("Starting: {}", message));

        let result = f();

        let elapsed = start.elapsed();
        self.info(&format!(
            "Completed: {} ({})",
            message,
            format_duration(elapsed)
        ));

        result
    }

    pub fn progress(&self, current: usize, total: usize, message: &str) {
        let _percentage = (current as f64 / total as f64 * 100.0) as u64;
        let pb = ProgressBar::new(total as u64);

        pb.set_style(
            ProgressStyle::default_bar()
                .template(&format!(
                    "{}: [{{bar:30}}] {{percent}}% ({{pos}}/{{len}})",
                    message
                ))
                .unwrap()
                .progress_chars("█▉▊▋▌▍▎▏  "),
        );

        pb.set_position(current as u64);

        if current >= total {
            pb.finish_and_clear();
            println!();
        }
    }
}

impl Default for Logger {
    fn default() -> Self {
        Self::new(LogLevel::Info)
    }
}

#[allow(dead_code)]
fn format_duration(d: Duration) -> String {
    if d.as_secs() > 60 {
        let minutes = d.as_secs() / 60;
        let seconds = d.as_secs() % 60;
        format!("{}m {}s", minutes, seconds)
    } else if d.as_secs() > 0 {
        format!("{:.2}s", d.as_secs_f64())
    } else {
        format!("{:.2}ms", d.as_millis() as f64)
    }
}

#[allow(dead_code)]
pub struct FileLogger {
    logger: Logger,
}

#[allow(dead_code)]
impl FileLogger {
    pub fn new(filename: &str) -> Self {
        let file = std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(filename)
            .unwrap();

        Self {
            logger: Logger {
                level: LogLevel::Info,
                use_colors: false,
                output: Mutex::new(Box::new(file)),
            },
        }
    }

    pub fn info(&self, message: &str) {
        self.logger.info(message);
    }

    pub fn error(&self, message: &str) {
        self.logger.error(message);
    }
}

#[allow(dead_code)]
pub struct MultiLogger {
    loggers: Vec<Logger>,
}

#[allow(dead_code)]
impl MultiLogger {
    pub fn new(loggers: Vec<Logger>) -> Self {
        Self { loggers }
    }

    pub fn debug(&self, message: &str) {
        for logger in &self.loggers {
            logger.debug(message);
        }
    }

    pub fn info(&self, message: &str) {
        for logger in &self.loggers {
            logger.info(message);
        }
    }

    pub fn warn(&self, message: &str) {
        for logger in &self.loggers {
            logger.warn(message);
        }
    }

    pub fn error(&self, message: &str) {
        for logger in &self.loggers {
            logger.error(message);
        }
    }

    pub fn fatal(&self, message: &str) {
        for logger in &self.loggers {
            logger.fatal(message);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_log_levels() {
        let logger = Logger::new(LogLevel::Info);
        logger.debug("This should not appear");
        logger.info("This should appear");
        logger.warn("This should appear");
        logger.error("This should appear");
    }

    #[test]
    fn test_with_timing() {
        let logger = Logger::new(LogLevel::Info);
        let result = logger.with_timing("Test operation", || {
            std::thread::sleep(Duration::from_millis(10));
            42
        });
        assert_eq!(result, 42);
    }

    #[test]
    fn test_format_duration() {
        assert!(format_duration(Duration::from_millis(500)).contains("ms"));
        assert!(format_duration(Duration::from_secs(5)).contains("s"));
        assert!(format_duration(Duration::from_secs(90)).contains("m"));
    }
}
