class MLPSinatra < Sinatra::Application

  # Signup new player
  post '/player' do
    player = params[:player]
    if Player.signup(player[:name], player[:email], player[:password])
      status 200
      email(address:player[:email],
              title:"Hello #{player[:name]}!",
               body:welcome_message)
    else
      status 400
    end
  end

  # Get all players (no passwords or api_keys)
  get '/players' do
    status 200
    Player.all_sanitized.to_json
  end

  # password recovery send email
  get '/player/:email/email_password_reset_link' do
    player = Player.first(:email => params[:email])
    if player
      email(address:player.email,
              title:"Forgot your password? That's cool.",
               body:lost_password_email_for(player))
      status 200
    else
      status 400
    end
  end

  # password reset page
  get '/player/:player_id/reset_password/:requester_api_key' do
    player = Player.first(:id => params[:player_id].to_i)
    if player && player.api_key == params[:requester_api_key]
      status 200
      reset_password_content
    else
      status 400
    end
  end

  # password reset action
  post '/player/:player_id/reset_password/:requester_api_key' do
    player = Player.first(:id => params[:player_id].to_i)
    if player && player.api_key == params[:requester_api_key]
      status 200
      if params['new_password'] == params['new_password_confirmed']
        hashed_password = BCrypt::Password.create(params['new_password'], :cost => 10)
        player.update(:hashed_password => hashed_password)
        "Password Saved."
      else
        "Passwords don't match"
      end
    else
      status 400
    end
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
    invited_leagues = Player.invited_leagues(params)
    if invited_leagues
      status 200
      invited_leagues.to_json
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

  # get a player's team invites
  get '/player/:player_id/season/:season_id/invited_teams/:requester_api_key' do
    invited_teams = Player.invited_teams(params)
    if invited_teams
      status 200
      invited_teams.to_json
    else
      status 400
    end
  end

  # accept a team invite
  put '/player/:player_id/accept_team/:team_id/:requester_api_key' do
    if Player.team_invite(:accept, params)
      status 200
    else
      status 400
    end
  end

  # decline a team invite
  put '/player/:player_id/decline_team/:team_id/:requester_api_key' do
    if Player.team_invite(:decline, params)
      status 200
    else
      status 400
    end
  end
end

def reset_password_content
"<html>
<head>
<script>
function check_passwords() {
  p1 = document.getElementsByName('new_password')[0].value;
  p2 = document.getElementsByName('new_password_confirmed')[0].value;
  if(p1.length < 4) alert('Valid passwords are at least 4 characters long.');
  else if(p1 != p2) alert('Passwords must match.');
  else alert('Password Reset!');
}
</script>
</head>
<body>
<form method='post'>
New Password <input type='text' name='new_password'></br>
New Password (Confirm) <input type='text' name='new_password_confirmed'></br>
<input type='submit' value='Reset' onclick='check_passwords()'>
</form>
</body>
</html>"
end

def email(options)
  body = "<img src='http://i.imgur.com/g0jEw2M.png' style='border-radius:10px;width:150px;height:150px;'><h1>#{options[:title]}</h1><br>#{options[:body]}"
  Pony.mail(:to => options[:address], :from => 'hello@mlp.com', :subject => options[:title], :headers => {'Content-Type'=>'text/html'}, :body => body, :via_options => PonyMailOptions)
end

def lost_password_email_for(player)
  base = 'http://mlp-sinatra.herokuapp.com'
  "<a style='font-size:16pt;' href='#{base}/player/#{player.id}/reset_password/#{player.api_key}'>Here's a link to reset it.</a>"
end

def welcome_message
  "<span style='font-size:14pt;'>Welcome to Major League Pong.</span>"
end
