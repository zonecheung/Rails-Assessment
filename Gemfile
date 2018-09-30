source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.1'

gem 'attr_encrypted', '~> 3.1.0'
# Have to use the gem from fork because of OpenSSL::Cipher::Cipher is deprecated warnings.
gem 'aes', '~> 0.5.0', git: 'https://github.com/jalerson/aes'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'
gem 'dotenv-rails', groups: [:development, :test]

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use sidekiq to handle background jobs.
gem 'sidekiq', '~> 5.2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.1', group: :doc
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 3.8.0'
end

group :development do
  gem 'rubocop', '~> 0.59.2', require: false

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot_rails', '~> 4.11.1'
end
