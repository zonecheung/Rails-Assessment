require 'test_helper'

class EncryptedStringsControllerTest < ActionController::TestCase
  def setup
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test 'POST #create saves new EncryptedString' do
    assert_difference 'EncryptedString.count' do
      post :create, params: { encrypted_string: { value: 'to encrypt' } }
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert json['token']
  end

  test 'POST #create returns invalid when value does not exist' do
    assert_no_difference 'EncryptedString.count' do
      post :create, params: { encrypted_string: { value: nil } }
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Value can't be blank", json['message']
  end

  test 'get #show returns the decrypted value' do
    @encrypted_string = EncryptedString.create!(value: 'decrypted string')

    get :show, params: { token: @encrypted_string.token }

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 'decrypted string', json['value']
  end

  test 'get #show returns 404 for invalid token' do
    get :show, params: { token: 'does not exist' }

    assert_response :not_found
  end

  test 'delete #destroy removes the token from the database' do
    @encrypted_string = EncryptedString.create!(value: 'value to destroy')

    assert_difference 'EncryptedString.count', -1 do
      post :destroy, params: { token: @encrypted_string.token }
    end

    assert_response :success
  end

  test 'delete #destroy returns 404 for invalid token' do
    delete :destroy, params: { token: 'does not exist' }

    assert_response :not_found
  end

  def setup_mock_for_destroy
    mock = Minitest::Mock.new

    def mock.destroy
      false
    end

    def mock.nil?
      false
    end

    def mock.errors
      errors_mock = Minitest::Mock.new
      def errors_mock.full_messages
        ['You shall not pass!', 'Fly you fool!']
      end
      errors_mock
    end
    mock
  end

  test 'delete #destroy returns 422 on error' do
    @encrypted_string = EncryptedString.create!(value: 'value to destroy')

    EncryptedString.stub :find_by, setup_mock_for_destroy do
      post :destroy, params: { token: @encrypted_string.token }
    end

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_equal 'You shall not pass! and Fly you fool!', json['message']
  end
end
