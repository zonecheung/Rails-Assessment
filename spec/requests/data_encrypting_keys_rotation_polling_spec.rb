require 'rails_helper'

def setup_encrypted_strings(size = 5)
  data_key = DataEncryptingKey.primary ||
             FactoryBot.create(:data_encrypting_key, primary: true)
  1.upto(size) do |n|
    FactoryBot.create(:encrypted_string, value: "My Heart Will Go On #{n}")
  end
end

describe 'DataEncryptingKey rotation polling', type: :request do
  before(:each) do
    DataEncryptingKeyRotationJob.clear_rotation_status
    setup_encrypted_strings(1500)
  end

  it 'should have 1500 encrypted strings in the table' do
    expect(EncryptedString.count).to eql(1500)
  end

end
