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
  get '/player/:player_id/leagues/:requester_api_key' do
    leagues = Player.leagues(params)
    if leagues
      status 200
      leagues.to_json
    else
      status 400
    end
  end

  # get a player's league invites
  get '/player/:player_id/invited_leagues/:requester_api_key' do
    league_invites = Player.league_invites(params)
    if league_invites
      status 200
      league_invites.to_json
    else
      status 400
    end
  end

  # accept a league invite
  put '/player/:player_id/accept_league/:league_id/:requester_api_key' do
    if Player.league_invite(:accept, params)
      status 200
    else
      status 400
    end
  end

  # decline a league invite
  delete '/player/:player_id/decline_league/:league_id/:requester_api_key' do
    if Player.league_invite(:decline, params)
      status 200
    else
      status 400
    end
  end
end