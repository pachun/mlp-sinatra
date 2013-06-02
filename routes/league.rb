class MLPSinatra < Sinatra::Application

  # create a league
  post '/league/:requester_api_key' do
    new_league = League.new_with(params)
    if new_league
      status 200
      {:id => new_league.id}.to_json
    else
      status 400
    end
  end

  # invite player to league
  post '/league/:league_id/invite/:player_id/:requester_api_key' do
    invited = League.invite(params)
    if invited
      status 200
    else
      status 400
    end
  end

  # get a list of all players in & out of the league
  get '/league/:league_id/invitable_players/:requester_api_key' do
    invitable_players = League.invitable_players(params)
    if invitable_players
      status 200
      invitable_players.to_json
    else
      status 400
    end
  end

  # update league info
  put '/league/:league_id/:requester_api_key' do
    updated = League.update(params)
    if updated
      status 200
    else
      status 400
    end
  end

  # get a list of all players in the league
  get '/league/:league_id/players/:requester_api_key' do
    players = League.players(params)
    if players
      status 200
      players.to_json
    else
      status 400
    end
  end
end
