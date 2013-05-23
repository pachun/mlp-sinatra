class MLPSinatra < Sinatra::Application

  # create a league
  post 'league/:api_key' do
    if League.new_with(:league => params[:league], :commissioner_key => params[:api_key])
      status 200
    else
      status 400
    end
  end

  # add a league referee
  post '/league/:league_id/add_referee/:player_id/:api_key' do
    result = League.add_referee(:league_id => params[:league_id],
                                :player_id => params[:player_id],
                                :commissioner_key => params[:api_key])
    case result
    when 'missing info'
      status 203
      # partial information

    when 'no permission'
      status 403
      # forbidden

    when 'player not in league'
      status 400
      # bad request

    when 'failed'
      status 304
      # not modified

    when 'updated'
      status 200
      # OK
    end
  end

  # update league info
  put '/league/:league_id/:api_key' do
    updated = League.update(:league_id => params[:league_id],
                            :commissioner_key => params[:api_key],
                            :league_changes => params[:league])
    if updated
      status 200
    else
      status 400
    end
  end

  # invite player to league
  post '/league/:league_id/invite/:player_id/:api_key' do
    invited = League.invite(:league_id => params[:league_id],
                            :player_id => params[:player_id],
                            :commissioner_key => params[:api_key])
    if invited
      status 200
    else
      status 400
    end
  end
end
