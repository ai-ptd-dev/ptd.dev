use anyhow::Result;
use serde_json::json;

pub struct VersionCommand {
    json_output: bool,
}

impl VersionCommand {
    pub const VERSION: &'static str = "1.0.0";
    pub const BUILD_DATE: &'static str = "2025-01-15";

    pub fn new(json_output: bool) -> Self {
        Self { json_output }
    }

    pub fn execute(&self) -> Result<()> {
        let version_info = self.build_version_info();

        if self.json_output {
            println!("{}", serde_json::to_string_pretty(&version_info)?);
        } else {
            self.display_formatted(&version_info);
        }

        Ok(())
    }

    fn build_version_info(&self) -> serde_json::Value {
        json!({
            "name": "PTD Ruby CLI",
            "version": Self::VERSION,
            "build_date": Self::BUILD_DATE,
            "ruby_version": format!("Rust {}", env!("CARGO_PKG_RUST_VERSION")),
            "platform": std::env::consts::OS,
            "description": "Polyglot Transpilation Development Reference Implementation",
            "repository": "https://github.com/ai-ptd-dev/ptd-ruby-cli"
        })
    }

    fn display_formatted(&self, info: &serde_json::Value) {
        println!("╔═══════════════════════════════════════════════════════════╗");
        println!("║                    PTD Ruby CLI (Rust)                    ║");
        println!("╠═══════════════════════════════════════════════════════════╣");
        println!(
            "║ Version:      {:44} ║",
            info["version"].as_str().unwrap_or("")
        );
        println!(
            "║ Build Date:   {:44} ║",
            info["build_date"].as_str().unwrap_or("")
        );
        println!(
            "║ Rust Version: {:44} ║",
            info["ruby_version"].as_str().unwrap_or("")
        );
        println!(
            "║ Platform:     {:44} ║",
            info["platform"].as_str().unwrap_or("")
        );
        println!("╠═══════════════════════════════════════════════════════════╣");
        println!(
            "║ {:^57} ║",
            info["description"].as_str().unwrap_or("")
        );
        println!("╚═══════════════════════════════════════════════════════════╝");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_version_constant() {
        assert_eq!(VersionCommand::VERSION, "1.0.0");
    }

    #[test]
    fn test_build_date_constant() {
        assert_eq!(VersionCommand::BUILD_DATE, "2025-01-15");
    }

    #[test]
    fn test_default_output() {
        let cmd = VersionCommand::new(false);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_json_output() {
        let cmd = VersionCommand::new(true);
        assert!(cmd.execute().is_ok());
    }

    #[test]
    fn test_version_info_structure() {
        let cmd = VersionCommand::new(false);
        let info = cmd.build_version_info();
        
        assert!(info["name"].is_string());
        assert!(info["version"].is_string());
        assert!(info["build_date"].is_string());
        assert!(info["platform"].is_string());
        assert!(info["description"].is_string());
        assert!(info["repository"].is_string());
    }
}