class DataEncryptingKeysController < ApplicationController
  before_action :detect_existing_job
  before_action :reject_job_if_exists, only: :rotate

  def rotate
    # NOTE: Set 1 minute delay to test the 'queued' status.
    DataEncryptingKeyRotationJob.set(wait: 1.minute).perform_later
    render json: { message: DataEncryptingKey::QUEUED }
  end

  def rotate_status
    render json: { message: @message }
  end

  private

  def detect_existing_job
    # NOTE: We can detect sidekiq for the queue/process, but that means we tie
    # =>    our code to the gem, and it might break if the gem is modified.
    @message = case Redis.new.get(DataEncryptingKeyRotationJob::KEY)
               when 'queued'
                 DataEncryptingKey::QUEUED
               when 'in progress'
                 DataEncryptingKey::IN_PROGRESS
               else
                 DataEncryptingKey::IDLE
               end
  end

  def reject_job_if_exists
    if @message != DataEncryptingKey::IDLE
      render json: { message: @message }, status: :unprocessable_entity
    end
  end
end
