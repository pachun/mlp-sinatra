class MLPSinatra < Sinatra::Application

  # Give me:  player => email, password
  #  Expect:  id, api_key
  post 'login' do
    player = params[:player]

    if player.nil? || !player.has_key?(:email) || !player.has_key?(:password)
      status 400
    else
      real_player = Player.first(:email => player[:email])

      if real_player && real_player.hashed_password == player[:password]
        status 200
        {:id => real_player.id, :api_key => real_player.api_key}.to_json
      end
    end
  end

end
