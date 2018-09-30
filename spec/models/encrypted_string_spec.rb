require 'rails_helper'

describe EncryptedString, 'validations', type: :model do
  let!(:data_key) { FactoryBot.create(:data_encrypting_key, primary: true) }
  subject { FactoryBot.build(:encrypted_string, value: 'My Heart Will Go On') }

  it { is_expected.to be_valid }

  it 'should generate the token before validation' do
    subject.valid?
    expect(subject.token).not_to be_nil
  end

  it 'should assign the data_encrypting_key before validation' do
    subject.valid?
    expect(subject.data_encrypting_key).to eql(data_key)
  end

  describe 'when value is blank' do
    before(:each) do
      subject.value = ''
    end

    it { is_expected.to_not be_valid }
  end

  describe 'when data_encrypting_key is blank' do
    before(:each) do
      subject.data_encrypting_key = nil
    end

    it { is_expected.to be_valid }

    it 'should reassign back to primary key' do
      subject.valid?
      expect(subject.data_encrypting_key).to eql(data_key)
    end
  end
end
