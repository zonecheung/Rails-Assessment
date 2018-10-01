Rails.application.routes.draw do
  defaults format: :json do
    resources :encrypted_strings,
              param: :token, only: %i[create show destroy]

    post '/data_encrypting_keys/rotate',
         to: 'data_encrypting_keys#rotate'
    get  '/data_encrypting_keys/rotate/status',
         to: 'data_encrypting_keys#rotate_status'
  end
end
