// Rust tests for hello command
// Located alongside hello_spec.rb for easy comparison

#[cfg(test)]
mod tests {
    use crate::commands::hello::HelloCommand;

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
}