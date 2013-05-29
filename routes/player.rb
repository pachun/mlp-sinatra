class MLPSinatra < Sinatra::Application

  # Signup new player
  post '/player' do
    player = params[:player]
    if Player.signup(player[:name], player[:email], player[:password])
      status 200
    else
      status 400
    end
  end

  # Get all players (no passwords or api_keys)
  get '/players' do
    status 200
    Player.all_sanitized.to_json
  end

  # get a player's leagues
  post '/player/:player_id/leagues/:requester_api_key' do
    leagues = Player.leagues(params)
    if leagues
      status 200
      leagues.to_json
    else
      status 400
    end
  end

  # get a player's league invites
  post '/player/:player_id/league_invites/:requester_api_key' do
    league_invites = Player.league_invites(params)
    if league_invites
      status 200
      league_invites.to_json
    else
      status 400
    end
  end
end
