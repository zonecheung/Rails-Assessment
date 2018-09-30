Rails.application.routes.draw do
  resources :encrypted_strings,
            param: :token, only: %i[create show destroy],
            defaults: { format: 'json' }

  post '/data_encrypting_keys/rotate',
       to: 'data_encrypting_keys#rotate', defaults: { format: 'json' }
  get  '/data_encrypting_keys/rotate/status',
       to: 'data_encrypting_keys#rotate_status', defaults: { format: 'json' }
end
