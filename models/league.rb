class League
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String
  property :commissioner_id, Integer
  property :current_season_id, Integer, :default => 0

  # league rules
  property :players_per_team, Integer, :default => 2
  property :plays_balls_back, Boolean, :default => false
  property :extra_point_cups, String, :default => ''
  property :rerack_cups, String, :default => '3,6'

  # relations
  has n, :seasons

  has n, :league_players
  has n, :players, :through => :league_players
end
