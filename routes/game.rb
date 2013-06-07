class MLPSinatra < Sinatra::Application
  post '/game/:requester_api_key' do
    if Game.new_with(params)
      status 200
    else
      status 400
    end
  end
end
