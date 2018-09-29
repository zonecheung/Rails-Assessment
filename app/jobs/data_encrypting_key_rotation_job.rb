class DataEncryptingKeyRotationJob < ApplicationJob
  KEY = "#{Rails.env}:active_jobs:data_encrypting_key_rotation_job"

  queue_as :default

  # NOTE: This is just a way to set the state of the job, we can use a
  # =>    different method if we like.
  after_enqueue  { |job| Redis.new.set(KEY, 'queued') }
  before_perform { |job| Redis.new.set(KEY, 'in progress') }
  after_perform  { |job| Redis.new.del(KEY) }

  def perform
    DataEncryptingKey.rotate!
  end
end
