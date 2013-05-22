class Game
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :scheduled_at, DateTime, :default => Time.now

  # when and results
  property :scheduled_time, DateTime
  property :winning_team_id, Integer
  property :was_played, Boolean, :default => false

  # playoff games only
  property :bracket_round, Integer, :default => 0
  property :is_playoff_game, Boolean, :default => false

  # relations
  belongs_to :season
  has n, :rounds

  has n, :team_games
  has n, :games, :through, :team_games
end
