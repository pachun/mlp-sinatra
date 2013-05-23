class MLPSinatra < Sinatra::Application

  # Signup new player
  post '/player' do
    player = params[:player]
    if Player.signup(player[:full_name], player[:email], player[:password])
      status 200
    else
      status 400
    end
  end

  # Get all players (no passwords or api_keys)
  get '/players' do
    status 200
    Player.all_sanitized
  end
end
