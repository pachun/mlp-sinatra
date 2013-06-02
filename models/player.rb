class Player
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :registered_at, DateTime, :default => Time.now

  # general
  property :name, String, :length => 5..50, :required => true
  property :email, String, :unique => true, :length => 6..75, :required => true

  # authentication
  property :api_key, String, :length => 32, :required => true
  property :hashed_password, BCryptHash, :required => true

  # relations
  has n, :shots

  has n, :league_players
  has n, :leagues, :through => :league_players

  def self.signup(name, email, password)
    hashed_password = BCrypt::Password.create(password, :cost => 10)
    api_key = (0...32).map { (65 + rand(26)).chr }.join
    new_player = Player.create(
      :name => name,
      :email => email,
      :hashed_password => hashed_password,
      :api_key => api_key
    )
    new_player.save
  end

  def self.all_sanitized
    players = Player.all(:order => [:name.asc])
    players.map! { |player| Player.sanitize(player) }
    players
  end

  def self.sanitize(player)
    {:id => player.id, :name => player.name, :email => player.email, :registered_at => player.registered_at}
  end

  def self.leagues(info)
    player = Player.first(:id => info[:player_id].to_i)
    return false if player.api_key != info[:requester_api_key]
    league_ids = []
    player.league_players.each do |invite|
      league_ids << invite.league_id if invite.accepted_invite
    end
    league_ids.map { |id| League.with_commissioner_and_season( League.first(:id => id) ) }
  end

  def self.league_invites(info)
    player = Player.first(:id => info[:player_id].to_i)
    return false if player.api_key != info[:requester_api_key]
    league_ids = []
    player.league_players.each do |invite|
      league_ids << invite.league_id if !invite.accepted_invite
    end
    league_ids.map { |id| League.with_commissioner( League.first(:id => id) ) }
  end

  def self.league_invite(response, info)
    player_id = info[:player_id].to_i
    league_id = info[:league_id].to_i
    player = Player.first(:id => player_id)
    return false if player.api_key != info[:requester_api_key]
    league_player = LeaguePlayer.first(:league_id => league_id, :player_id => player_id)
    return false if !league_player

    if response == :accept
      league_player.update(:accepted_invite => true, :accepted_at => Time.now)
    else
      league_player.destroy
    end
  end
end
