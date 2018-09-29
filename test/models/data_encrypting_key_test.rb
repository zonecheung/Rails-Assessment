require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  test 'validations' do
    data_key = DataEncryptingKey.new
    assert_not data_key.valid?
    data_key.key = 'randomer' * 8
    assert data_key.valid?
  end

  test '.generate!' do
    assert_difference 'DataEncryptingKey.count' do
      data_key = DataEncryptingKey.generate!
      assert data_key
      assert_not data_key.primary
      assert data_key.persisted?
    end
  end

  test '.generate!(primary: true)' do
    assert_difference 'DataEncryptingKey.count' do
      data_key = DataEncryptingKey.generate!(primary: true)
      assert data_key
      assert data_key.primary
      assert data_key.persisted?
    end
  end

  def generate_primary
    DataEncryptingKey.primary || DataEncryptingKey.generate!(primary: true)
  end

  test '.rotate!' do
    data_key = generate_primary
    size = DataEncryptingKey.count    # 2 in fixtures + 1 primary.
    assert_not_equal 1, size

    # It should reduce the size.
    assert_difference 'DataEncryptingKey.count', 1 - size do
      DataEncryptingKey.rotate!
    end
    # It should change the primary record.
    assert_not_equal data_key.id, DataEncryptingKey.primary.id
  end

  def generate_encrypted_strings(size = 5)
    encrypted_strings.each(&:destroy)   # Clean up the fixtures first.
    1.upto(size) do |n|
      EncryptedString.create!(value: 'My Heart Will Go On')
    end
  end

  def assert_encrypted_strings(data_key)
    EncryptedString.find_each do |ec|
      assert_equal ec.data_encrypting_key_id, data_key.id
      assert_equal ec.value, 'My Heart Will Go On'
    end
  end

  test '.rotate! (encrypted strings)' do
    data_key = generate_primary
    generate_encrypted_strings(10)

    assert_equal EncryptedString.count, 10

    # Check encrypted strings before rotation.
    assert_encrypted_strings(data_key)

    DataEncryptingKey.rotate!

    # It should change the primary record.
    new_data_key = DataEncryptingKey.primary
    assert_not_equal data_key.id, new_data_key.id

    # Check encrypted strings after rotation.
    assert_encrypted_strings(new_data_key)
  end
end
