require 'rails_helper'

describe 'DataEncryptingKey rotation', type: :request do
  before(:each) do
    DataEncryptingKeyRotationJob.clear_rotation_status
  end

  it 'should return idle message if there\'s no process' do
    get '/data_encrypting_keys/rotate/status'

    expect(response).to have_http_status(200)
    expect(response.body).to eql(
      { message: 'No key rotation queued or in progress' }.to_json
    )
  end

  it 'should return queued message if the rotation is called' do
    post '/data_encrypting_keys/rotate'

    expect(response).to have_http_status(200)
    expect(response.body).to eql(
      { message: 'Key rotation has been queued' }.to_json
    )
  end

  describe 'when a rotate request has been submitted' do
    before(:each) do
      post '/data_encrypting_keys/rotate'
    end

    it 'should return queued message when checking the status' do
      get '/data_encrypting_keys/rotate/status'

      expect(response).to have_http_status(200)
      expect(response.body).to eql(
        { message: 'Key rotation has been queued' }.to_json
      )
    end

    it 'should return queued message with status 422 when resubmitted' do
      post '/data_encrypting_keys/rotate'

      expect(response).to have_http_status(422)
      expect(response.body).to eql(
        { message: 'Key rotation has been queued' }.to_json
      )
    end

    it 'should return idle message when it\'s (probably?) processed' do
      sleep(6)
      get '/data_encrypting_keys/rotate/status'

      expect(response).to have_http_status(200)
      expect(response.body).to eql(
        { message: 'No key rotation queued or in progress' }.to_json
      )
    end
  end
end
