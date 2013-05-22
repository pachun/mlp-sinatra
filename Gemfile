source 'https://rubygems.org'

# server functionality
gem 'sinatra'
gem 'thin'

# data transfer
gem 'json'
gem 'dm-serializer'

# security
gem 'bcrypt-ruby'

# database / ORM

gem 'data_mapper'
gem 'dm-core'
gem 'dm-constraints'

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :development do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end
