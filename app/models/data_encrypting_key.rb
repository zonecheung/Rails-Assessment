class DataEncryptingKey < ApplicationRecord
  attr_encrypted :key, key: :key_encrypting_key

  validates :key, presence: true

  def self.primary
    find_by(primary: true)
  end

  def self.generate!(attrs={})
    create!(attrs.merge(key: AES.key))
  end

  def self.rotate!
    # NOTE: We don't need to rescue the errors, it will be handled by
    # =>    Sidekiq.
    ActiveRecord::Base.transaction do
      # Set all primary records to false.
      self.where(primary: true).update_all(primary: false)
      # Generate a new primary record.
      new_key = self.generate!(primary: true)
      # Process all encrypted_strings.
      EncryptedString.where(['data_encrypting_key_id != ?', new_key.id])
                     .find_each do |encrypted_string|
        value = encrypted_string.value
        encrypted_string.update_attributes!(
          data_encrypting_key: new_key, value: value
        )
      end
      # Remove all other keys.
      self.where(['id != ?', new_key.id]).destroy_all
    end
  end

  def key_encrypting_key
    ENV['KEY_ENCRYPTING_KEY'] || 'bluejays' * 4
  end
end
