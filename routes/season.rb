class MLPSinatra < Sinatra::Application
  post '/season/:requester_api_key' do
    new_season = Season.new_with(params)
    if new_season
      status 200
      new_season.to_json
    else
      status 400
    end
  end

  get '/season/:season_id/teams/:requester_api_key' do
    teams = Season.teams(params)
    if teams
      status 200
      teams.to_json
    else
      status 400
    end
  end

  get '/season/:season_id/games/:requester_api_key' do
    games = Season.games(params)
    if games
      status 200
      games.to_json
    else
      status 400
    end
  end

  put '/season/:season_id/lock_teams/:requester_api_key' do
    if Season.lock_teams(params)
      status 200
    else
      status 400
    end
  end
end
