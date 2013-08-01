class MLPSinatra < Sinatra::Application
  post '/game/:requester_api_key' do
    # security checks here
    if Game.new_with(params)
      status 200
    else
      status 400
    end
  end

  put '/game/:game_id/:requester_api_key' do
    requester = Player.first(:api_key => params[:requester_api_key])
    game = Game.get(params[:game_id].to_i)
    return false if requester.nil? || game.nil?
    return false unless game.season.league.includes?(requester)

    if game.score(params)
      status 200
    else
      status 400
    end
  end

  get '/game/:game_id/:requester_api_key' do
    requester = Player.first(:api_key => params[:requester_api_key])
    game = Game.get(params[:game_id].to_i)
    return false if requester.nil? || game.nil?
    return false unless game.season.league.includes?(requester)

    game.bundle_details
  end
end
