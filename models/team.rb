class Team
  include DataMapper::Resource

  # meta
  property :id, Serial

  # general
  property :name, String
  property :proposed_at, DateTime, :default => Time.now
  property :finalized_at, DateTime
  property :finalized, Boolean, :default => false

  # playoff info
  property :playoff_seat, Integer, :default => 0
  property :eliminated, Boolean, :default => false

  # relations
  belongs_to :season

  has n, :team_games
  has n, :games, :through => :team_games

  has n, :team_players
  has n, :players, :through => :team_players
end
