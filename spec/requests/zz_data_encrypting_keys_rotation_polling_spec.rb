require 'rails_helper'

RECORD_COUNT = 1500

def setup_encrypted_strings_for_polling(size = RECORD_COUNT)
  1.upto(size) do |n|
    FactoryBot.create(:encrypted_string, value: "My Heart Will Go On #{n}")
  end
end

def poll_rotation_request(show_message = false)
  begin
    sleep(0.5)
    get '/data_encrypting_keys/rotate/status'

    expect(response).to have_http_status(200)

    json = JSON.parse(response.body)
    puts "Response message: #{json['message']}" if show_message
    expect(DataEncryptingKeyRotationJob::MESSAGES).to(
      include(json['message'])
    )

    # Try to submit a new rotate request.
    if json['message'] != DataEncryptingKeyRotationJob::IDLE
      post '/data_encrypting_keys/rotate'
      expect(response).to have_http_status(422)
    end
  end while json['message'] != DataEncryptingKeyRotationJob::IDLE
end

# NOTE: We need to run this last so that it won't block faster specs.
describe 'DataEncryptingKey rotation (polling)', type: :request do
  let!(:data_key) do
    DataEncryptingKey.primary ||
      FactoryBot.create(:data_encrypting_key, primary: true)
  end

  before(:each) do
    DataEncryptingKeyRotationJob.clear_rotation_status
    setup_encrypted_strings_for_polling(RECORD_COUNT)
  end

  it 'should have correct properties in all encrypted strings' do
    expect(EncryptedString.count).to eql(RECORD_COUNT)
    EncryptedString.find_each do |es|
      expect(es.data_encrypting_key).to eql(data_key)
      expect(es.value).to match(/My Heart Will Go On/)
    end
  end

  it 'should return idle status when there\'s no process' do
    get '/data_encrypting_keys/rotate/status'

    expect(response).to have_http_status(200)
    expect(response.body).to eql(
      { message: DataEncryptingKeyRotationJob::IDLE }.to_json
    )
  end

  describe 'when rotation is requested',
           perform_enqueued_at: true, skip_db_cleaner: true do
    let!(:old_data_key) { data_key } # Capture old key before processing.

    before(:each) do
      ActiveJob::Base.queue_adapter = :async
      post '/data_encrypting_keys/rotate'
    end

    after(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should return correct results when being polled' do
      poll_rotation_request(true)

      new_data_key = DataEncryptingKey.primary

      expect(new_data_key).not_to eql(old_data_key)
      expect(EncryptedString.count).to eql(RECORD_COUNT)

      EncryptedString.find_each do |es|
        expect(es.data_encrypting_key).not_to eql(old_data_key)
        expect(es.data_encrypting_key).to eql(new_data_key)
        expect(es.value).to match(/My Heart Will Go On/)
      end
    end
  end
end
