class Player
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :registered_at, DateTime, :default => Time.now

  # general
  property :full_name, String
  property :email, String, :unique => true

  # authentication
  property :api_key, String
  property :hashed_password, BCryptHash

  # relations
  has n, :shots

  has n, :team_players
  has n, :teams, :through => :team_players

  has n, :league_players
  has n, :leagues, :through => :league_players
end
