class RemoveEncryptedStringsEncryptedValueSaltColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :encrypted_strings, :encrypted_value_salt
  end
end
