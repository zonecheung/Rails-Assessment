require 'rails_helper'

def setup_encrypted_strings(data_key, size = 5)
  1.upto(size) do |n|
    FactoryBot.create(:encrypted_string,
                      value: 'My Heart Will Go On',
                      data_encrypting_key: data_key)
  end
end

describe DataEncryptingKey, 'rotate!', type: :model do
  let(:data_key) do
    DataEncryptingKey.primary || DataEncryptingKey.generate!(primary: true)
  end

  before(:each) do
    setup_encrypted_strings(data_key, 10)
  end

  it 'should have 10 encrypted strings' do
    expect(EncryptedString.count).to eql(10)
  end

  it 'should have correct data_encrypting_key and value in encrypted strings' do
    EncryptedString.find_each do |ec|
      expect(ec.value).to eql('My Heart Will Go On')
      expect(ec.data_encrypting_key_id).to eql(data_key.id)
    end
  end

  describe 'after rotation' do
    let(:new_data_key) { DataEncryptingKey.primary }

    before(:each) do
      DataEncryptingKey.rotate!
    end

    it 'should have new primary record' do
      expect(new_data_key.id).not_to eql(data_key.id)
    end

    it 'should change the data_encrypting_key_id in encrypted strings' do
      EncryptedString.find_each do |ec|
        expect(ec.value).to eql('My Heart Will Go On')
        expect(ec.data_encrypting_key_id).to eql(new_data_key.id)
      end
    end
  end

  describe 'after a failed rotation' do
    let(:keys) { double('DataEncryptingKeys') }

    before(:each) do
      allow(DataEncryptingKey).to receive(:where).and_call_original
      allow(DataEncryptingKey).to(
        receive(:where).with(['id != ?', anything]).and_return(keys)
      )
      allow(keys).to receive(:destroy_all).and_raise('error!')
    end

    it 'should not change the primary record' do
      original_data_key = data_key
      expect { DataEncryptingKey.rotate! }.to raise_error('error!')
      expect(DataEncryptingKey.primary.id).to eql(original_data_key.id)
    end

    it 'should not change the data_encrypting_key_id in encrypted strings' do
      original_data_key = data_key
      lambda { DataEncryptingKey.rotate! }
      EncryptedString.find_each do |ec|
        expect(ec.value).to eql('My Heart Will Go On')
        expect(ec.data_encrypting_key_id).to eql(original_data_key.id)
      end
    end

    it 'should not change the encrypted strings size' do
      lambda { DataEncryptingKey.rotate! }
      expect(EncryptedString.count).to eql(10)
    end
  end
end
