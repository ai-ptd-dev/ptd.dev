use anyhow::{bail, Context, Result};
use csv::{Reader, Writer};
use serde::{Deserialize, Serialize};
use sha1::Sha1;
use sha2::{Digest, Sha256, Sha512};
use std::collections::HashMap;
use std::fs::{self, File};
use std::io::{Read, Write as _};
use std::path::Path;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum FileError {
    #[error("File not found: {0}")]
    NotFound(String),
    
    #[error("Failed to read {0}: {1}")]
    ReadError(String, String),
    
    #[error("Failed to write {0}: {1}")]
    WriteError(String, String),
    
    #[error("Invalid JSON: {0}")]
    InvalidJson(String),
    
    #[error("Invalid YAML: {0}")]
    InvalidYaml(String),
    
    #[error("Invalid CSV: {0}")]
    InvalidCsv(String),
    
    #[error("Unsupported format: {0}")]
    UnsupportedFormat(String),
    
    #[error("File operation failed: {0}")]
    OperationFailed(String),
}

pub struct FileHandler;

impl FileHandler {
    pub fn read<P: AsRef<Path>>(path: P) -> Result<String> {
        let path = path.as_ref();
        if !path.exists() {
            bail!(FileError::NotFound(path.display().to_string()));
        }

        fs::read_to_string(path)
            .with_context(|| format!("Failed to read file: {:?}", path))
    }

    pub fn write<P: AsRef<Path>>(path: P, content: &str) -> Result<()> {
        let path = path.as_ref();
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?;
        }

        fs::write(path, content)
            .with_context(|| format!("Failed to write file: {:?}", path))
    }

    pub fn read_json<T, P>(path: P) -> Result<T>
    where
        T: for<'de> Deserialize<'de>,
        P: AsRef<Path>,
    {
        let content = Self::read(&path)?;
        serde_json::from_str(&content)
            .map_err(|e| FileError::InvalidJson(e.to_string()).into())
    }

    pub fn write_json<T, P>(path: P, data: &T, pretty: bool) -> Result<()>
    where
        T: Serialize,
        P: AsRef<Path>,
    {
        let json = if pretty {
            serde_json::to_string_pretty(data)?
        } else {
            serde_json::to_string(data)?
        };

        Self::write(path, &json)
    }

    pub fn read_yaml<T, P>(path: P) -> Result<T>
    where
        T: for<'de> Deserialize<'de>,
        P: AsRef<Path>,
    {
        let content = Self::read(&path)?;
        serde_yaml::from_str(&content)
            .map_err(|e| FileError::InvalidYaml(e.to_string()).into())
    }

    pub fn write_yaml<T, P>(path: P, data: &T) -> Result<()>
    where
        T: Serialize,
        P: AsRef<Path>,
    {
        let yaml = serde_yaml::to_string(data)?;
        Self::write(path, &yaml)
    }

    pub fn read_csv<P>(path: P) -> Result<Vec<HashMap<String, String>>>
    where
        P: AsRef<Path>,
    {
        let file = File::open(path.as_ref())?;
        let mut reader = Reader::from_reader(file);
        let headers = reader.headers()?.clone();
        
        let mut records = Vec::new();
        for result in reader.records() {
            let record = result?;
            let mut map = HashMap::new();
            for (i, field) in record.iter().enumerate() {
                if let Some(header) = headers.get(i) {
                    map.insert(header.to_string(), field.to_string());
                }
            }
            records.push(map);
        }
        
        Ok(records)
    }

    pub fn write_csv<P>(path: P, data: &[HashMap<String, String>]) -> Result<()>
    where
        P: AsRef<Path>,
    {
        if data.is_empty() {
            return Self::write(path, "");
        }

        let file = File::create(path.as_ref())?;
        let mut writer = Writer::from_writer(file);
        
        // Write headers
        let headers: Vec<_> = data[0].keys().cloned().collect();
        writer.write_record(&headers)?;
        
        // Write data
        for row in data {
            let record: Vec<_> = headers.iter().map(|h| row.get(h).unwrap_or(&String::new()).clone()).collect();
            writer.write_record(&record)?;
        }
        
        writer.flush()?;
        Ok(())
    }

    pub fn copy<P, Q>(source: P, destination: Q) -> Result<()>
    where
        P: AsRef<Path>,
        Q: AsRef<Path>,
    {
        let source = source.as_ref();
        let destination = destination.as_ref();

        if !source.exists() {
            bail!(FileError::NotFound(source.display().to_string()));
        }

        if let Some(parent) = destination.parent() {
            fs::create_dir_all(parent)?;
        }

        fs::copy(source, destination)?;
        Ok(())
    }

    pub fn move_file<P, Q>(source: P, destination: Q) -> Result<()>
    where
        P: AsRef<Path>,
        Q: AsRef<Path>,
    {
        let source = source.as_ref();
        let destination = destination.as_ref();

        if !source.exists() {
            bail!(FileError::NotFound(source.display().to_string()));
        }

        if let Some(parent) = destination.parent() {
            fs::create_dir_all(parent)?;
        }

        fs::rename(source, destination)?;
        Ok(())
    }

    pub fn delete<P: AsRef<Path>>(path: P) -> Result<bool> {
        let path = path.as_ref();
        if !path.exists() {
            return Ok(false);
        }

        fs::remove_file(path)?;
        Ok(true)
    }

    pub fn exists<P: AsRef<Path>>(path: P) -> bool {
        path.as_ref().exists()
    }

    pub fn size<P: AsRef<Path>>(path: P) -> Result<u64> {
        let path = path.as_ref();
        if !path.exists() {
            bail!(FileError::NotFound(path.display().to_string()));
        }

        let metadata = fs::metadata(path)?;
        Ok(metadata.len())
    }

    pub fn checksum<P: AsRef<Path>>(path: P, algorithm: &str) -> Result<String> {
        let path = path.as_ref();
        if !path.exists() {
            bail!(FileError::NotFound(path.display().to_string()));
        }

        let mut file = File::open(path)?;
        let mut buffer = Vec::new();
        file.read_to_end(&mut buffer)?;

        let hash = match algorithm {
            "md5" => {
                let digest = md5::compute(&buffer);
                format!("{:x}", digest)
            }
            "sha1" => {
                let mut hasher = Sha1::new();
                hasher.update(&buffer);
                format!("{:x}", hasher.finalize())
            }
            "sha256" => {
                let mut hasher = Sha256::new();
                hasher.update(&buffer);
                format!("{:x}", hasher.finalize())
            }
            "sha512" => {
                let mut hasher = Sha512::new();
                hasher.update(&buffer);
                format!("{:x}", hasher.finalize())
            }
            _ => bail!("Unsupported algorithm: {}", algorithm),
        };

        Ok(hash)
    }

    pub fn stats<P: AsRef<Path>>(path: P) -> Result<FileStats> {
        let path = path.as_ref();
        if !path.exists() {
            bail!(FileError::NotFound(path.display().to_string()));
        }

        let metadata = fs::metadata(path)?;
        
        Ok(FileStats {
            size: metadata.len(),
            modified_at: metadata.modified()?,
            created_at: metadata.created().ok(),
            accessed_at: metadata.accessed().ok(),
            is_directory: metadata.is_dir(),
            is_file: metadata.is_file(),
            #[cfg(unix)]
            permissions: {
                use std::os::unix::fs::PermissionsExt;
                format!("{:o}", metadata.permissions().mode() & 0o777)
            },
            #[cfg(not(unix))]
            permissions: String::from("N/A"),
        })
    }

    pub fn atomic_write<P: AsRef<Path>>(path: P, content: &str) -> Result<()> {
        let path = path.as_ref();
        let temp_path = path.with_extension(format!("tmp.{}", std::process::id()));

        Self::write(&temp_path, content)?;
        fs::rename(&temp_path, path)?;

        Ok(())
    }
}

#[derive(Debug)]
pub struct FileStats {
    pub size: u64,
    pub modified_at: std::time::SystemTime,
    pub created_at: Option<std::time::SystemTime>,
    pub accessed_at: Option<std::time::SystemTime>,
    pub is_directory: bool,
    pub is_file: bool,
    pub permissions: String,
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_read_write() {
        let dir = TempDir::new().unwrap();
        let file_path = dir.path().join("test.txt");

        FileHandler::write(&file_path, "Hello, World!").unwrap();
        let content = FileHandler::read(&file_path).unwrap();

        assert_eq!(content, "Hello, World!");
    }

    #[test]
    fn test_json_operations() {
        #[derive(Serialize, Deserialize, PartialEq, Debug)]
        struct TestData {
            name: String,
            value: i32,
        }

        let dir = TempDir::new().unwrap();
        let file_path = dir.path().join("test.json");

        let data = TestData {
            name: "Test".to_string(),
            value: 42,
        };

        FileHandler::write_json(&file_path, &data, true).unwrap();
        let loaded: TestData = FileHandler::read_json(&file_path).unwrap();

        assert_eq!(data, loaded);
    }

    #[test]
    fn test_copy_file() {
        let dir = TempDir::new().unwrap();
        let source = dir.path().join("source.txt");
        let dest = dir.path().join("dest.txt");

        FileHandler::write(&source, "test content").unwrap();
        FileHandler::copy(&source, &dest).unwrap();

        assert!(dest.exists());
        assert_eq!(FileHandler::read(&dest).unwrap(), "test content");
    }

    #[test]
    fn test_move_file() {
        let dir = TempDir::new().unwrap();
        let source = dir.path().join("source.txt");
        let dest = dir.path().join("dest.txt");

        FileHandler::write(&source, "move me").unwrap();
        FileHandler::move_file(&source, &dest).unwrap();

        assert!(!source.exists());
        assert!(dest.exists());
        assert_eq!(FileHandler::read(&dest).unwrap(), "move me");
    }

    #[test]
    fn test_delete_file() {
        let dir = TempDir::new().unwrap();
        let file_path = dir.path().join("delete_me.txt");

        FileHandler::write(&file_path, "temporary").unwrap();
        let result = FileHandler::delete(&file_path).unwrap();

        assert!(result);
        assert!(!file_path.exists());
    }

    #[test]
    fn test_checksum() {
        let dir = TempDir::new().unwrap();
        let file_path = dir.path().join("checksum.txt");

        FileHandler::write(&file_path, "Hello World").unwrap();

        let sha256 = FileHandler::checksum(&file_path, "sha256").unwrap();
        assert_eq!(sha256.len(), 64); // SHA256 is 64 hex chars

        let md5 = FileHandler::checksum(&file_path, "md5").unwrap();
        assert_eq!(md5.len(), 32); // MD5 is 32 hex chars
    }
}