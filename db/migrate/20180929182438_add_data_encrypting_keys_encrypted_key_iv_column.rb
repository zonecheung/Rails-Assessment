class AddDataEncryptingKeysEncryptedKeyIvColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :data_encrypting_keys, :encrypted_key_iv, :string
  end
end
