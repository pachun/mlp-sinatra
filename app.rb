require 'sinatra'
require 'json'
require 'dm-core'
require 'bcrypt'
require 'dm-serializer'
require 'dm-constraints'
require 'pony'

PonyMailOptions = {
    :address        => 'smtp.mandrillapp.com',
    :port           => '587',
    :user_name      => 'hello@nickpachulski.com',#ENV['MANDRILL_USERNAME'],
    :password       => '7yB8q-7whP2pe0ZNvPa8cg',#ENV['MANDRILL_PASSWORD'],
    :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain         => "localhost.localdomain", # the HELO domain provided by the client to the server
    :enable_starttls_auto => false,
  }

class MLPSinatra < Sinatra::Application
  :enable_sessions
  set(:session_secret, "mlp-sinatra")

  get "/" do
    "hello world"
  end
end

require_relative 'routes/init'
require_relative 'models/init'
