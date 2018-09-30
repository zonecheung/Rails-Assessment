FactoryBot.define do
  factory :data_encrypting_key do
    key { 'bluejays' * 4 }
    primary { false }
  end
end
