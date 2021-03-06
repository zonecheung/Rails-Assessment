# frozen_string_literal: true

class DataEncryptingKeyRotationJob < ApplicationJob
  KEY = "#{Rails.env}:active_jobs:data_encrypting_key_rotation_job"

  IDLE        = 'No key rotation queued or in progress'
  QUEUED      = 'Key rotation has been queued'
  IN_PROGRESS = 'Key rotation is in progress'
  MESSAGES    = [IDLE, QUEUED, IN_PROGRESS].freeze

  queue_as :default

  # NOTE: This is just a way to set the state of the job, we can use a
  # =>    different method if we like.
  after_enqueue do |_job|
    DataEncryptingKeyRotationJob.update_rotation_status('queued')
  end
  before_perform do |_job|
    DataEncryptingKeyRotationJob.update_rotation_status('in progress')
  end
  after_perform do |_job|
    DataEncryptingKeyRotationJob.clear_rotation_status
  end

  def self.update_rotation_status(status)
    _redis.set(KEY, status)
  end

  def self.clear_rotation_status
    _redis.del(KEY)
  end

  def self.rotation_status
    _redis.get(KEY)
  end

  def self.rotation_status_message
    case self.rotation_status
    when 'queued'
      QUEUED
    when 'in progress'
      IN_PROGRESS
    else
      IDLE
    end
  end

  def perform
    DataEncryptingKey.rotate!
  end

  class << self
    private

    def _redis
      if defined?(@@_redis)
        @@_redis
      else
        @@_redis = Redis.new
      end
    end
  end
end
