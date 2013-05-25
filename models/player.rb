class Player
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :registered_at, DateTime, :default => Time.now

  # general
  property :full_name, String, :length => 5..50, :required => true
  property :email, String, :unique => true, :length => 6..75, :required => true

  # authentication
  property :api_key, String
  property :hashed_password, BCryptHash

  # relations
  has n, :shots

  has n, :team_players
  has n, :teams, :through => :team_players

  has n, :league_players
  has n, :leagues, :through => :league_players

  # register
  def self.signup(full_name, email, password)
    hashed_password = BCrypt::Password.create(password, :cost => 10)
    api_key = (0...32).map { (65 + rand(26)).chr }.join
    new_player = Player.create(
      :full_name => full_name,
      :email => email,
      :hashed_password => hashed_password,
      :api_key => api_key
    )
    new_player.save
  end

  # get a list of all the players (strip api_key & password)
  def self.all_sanitized
    players = Player.all(:order => [:full_name.asc])
    response = []
    players.each do |p|
      response << {:full_name => p.full_name, :email => p.email, :registered_at => p.registered_at}
    end
    response.to_json
  end
end
