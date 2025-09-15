require 'rspec'
require 'json'
require 'stringio'
require 'tempfile'

# Configure RSpec
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

# Helper method for capturing stdout
def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end

# Helper method for capturing stderr
def capture_stderr
  original_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr.string
ensure
  $stderr = original_stderr
end
