class EncryptedString < ApplicationRecord
  belongs_to :data_encrypting_key

  # NOTE: The previous :per_attribute_iv_and_salt is deprecated, we're using
  # =>    :per_attribute_iv now.
  # =>    See: https://github.com/attr-encrypted/attr_encrypted
  attr_encrypted :value, key: :encryption_key

  validates :token, presence: true, uniqueness: true
  validates :data_encrypting_key, presence: true
  validates :value, presence: true

  before_validation :set_token, :set_data_encrypting_key, on: :create

  private

  def encryption_key
    set_data_encrypting_key
    data_encrypting_key.key
  end

  def set_token
    begin
      self.token = SecureRandom.hex
    end while EncryptedString.where(token: self.token).present?
  end

  def set_data_encrypting_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
  end
end
