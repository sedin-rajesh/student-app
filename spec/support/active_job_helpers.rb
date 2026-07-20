# spec/support/active_job_helpers.rb
# Configure ActiveJob to use the test adapter for all job specs
RSpec.configure do |config|
  config.before(:each, type: :job) do
    ActiveJob::Base.queue_adapter = :test
  end
end
