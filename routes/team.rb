class MLPSinatra < Sinatra::Application
  post '/team/:requester_api_key' do
    new_team = Team.new_with(params)
    if new_team
      status 200
      new_team.to_json
    else
      status 400
    end
  end
end
