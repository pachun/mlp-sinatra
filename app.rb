require 'sinatra'
require 'json'
require 'dm-core'
require 'bcrypt'
require 'dm-serializer'
require 'dm-constraints'
require 'pony'

class MLPSinatra < Sinatra::Application
  :enable_sessions
  set(:session_secret, "mlp-sinatra")

  get "/" do
    "hello world"
  end
end

require_relative 'routes/init'
require_relative 'models/init'
