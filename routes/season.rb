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
end
