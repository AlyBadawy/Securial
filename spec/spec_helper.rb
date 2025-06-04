require "factory_bot_rails"
require "faker"
require "generator_spec"
require "shoulda-matchers"
require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.output_directory = "coverage"
SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = "lcov.info"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])

SimpleCov.start do
  enable_coverage :branch
  add_filter "/spec/"
  add_filter "/lib/securial/version.rb"
  track_files "lib/**/*.rb"
  minimum_coverage 95
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
