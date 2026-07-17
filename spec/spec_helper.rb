require "simplecov"

SimpleCov.start "rails" do
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Models",      "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Mailers",     "app/mailers"
  add_group "Jobs",        "app/jobs"
  add_group "PDFs",        "app/pdfs"

  minimum_coverage 80
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed
end
