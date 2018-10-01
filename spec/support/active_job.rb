RSpec.configure do |config|
  # config.include(RSpec::ActiveJob)

  # clean out the queue after each spec
  config.after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  config.around :each, perform_enqueued: true do |example|
    @old_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    example.run
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = @old_perform_enqueued_jobs
  end

  config.around :each, perform_enqueued_at: true do |example|
    @old_perform_enqueued_at_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
    example.run
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = @old_perform_enqueued_at_jobs
  end
end
