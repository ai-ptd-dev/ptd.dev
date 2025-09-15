use anyhow::Result;
use chrono::Local;

pub struct HelloCommand {
    name: String,
    uppercase: bool,
    repeat: usize,
}

impl HelloCommand {
    pub fn new(name: String, uppercase: bool, repeat: usize) -> Self {
        Self {
            name,
            uppercase,
            repeat,
        }
    }

    pub fn execute(&self) -> Result<()> {
        let greeting = self.build_greeting();

        for _ in 0..self.repeat {
            if self.uppercase {
                println!("{}", greeting.to_uppercase());
            } else {
                println!("{}", greeting);
            }
        }

        Ok(())
    }

    fn build_greeting(&self) -> String {
        let time_of_day = self.get_time_of_day();
        format!("{}, {}! Welcome to PTD Ruby CLI", time_of_day, self.name)
    }

    fn get_time_of_day(&self) -> &str {
        use chrono::Timelike;
        let hour = Local::now().hour();

        match hour {
            0..=11 => "Good morning",
            12..=17 => "Good afternoon",
            _ => "Good evening",
        }
    }
}

pub struct HelloResult {
    pub success: bool,
    pub message: String,
}

impl HelloResult {
    pub fn new(success: bool, message: String) -> Self {
        Self { success, message }
    }

    pub fn is_success(&self) -> bool {
        self.success
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_greeting() {
        let command = HelloCommand::new("Alice".to_string(), false, 1);
        assert!(command.execute().is_ok());
    }

    #[test]
    fn test_uppercase_option() {
        let command = HelloCommand::new("Bob".to_string(), true, 1);
        assert!(command.execute().is_ok());
    }

    #[test]
    fn test_repeat_option() {
        let command = HelloCommand::new("Charlie".to_string(), false, 3);
        assert!(command.execute().is_ok());
    }

    #[test]
    fn test_time_of_day() {
        let command = HelloCommand::new("Test".to_string(), false, 1);
        let tod = command.get_time_of_day();
        assert!(["Good morning", "Good afternoon", "Good evening"].contains(&tod));
    }

    #[test]
    fn test_build_greeting() {
        let command = HelloCommand::new("Test".to_string(), false, 1);
        let greeting = command.build_greeting();
        assert!(greeting.contains("Test"));
        assert!(greeting.contains("Welcome to PTD Ruby CLI"));
    }
}