class Game
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :scheduled_at, DateTime, :default => Time.now

  # when and results
  property :scheduled_time, DateTime
  property :winning_team_id, Integer
  property :was_played, Boolean, :default => false

  # team info
  property :home_team_id, Integer
  property :away_team_id, Integer

  # player info
  property :htp1_id, Integer
  property :htp2_id, Integer
  property :htp3_id, Integer
  def home_team_player1; Player.first(:id => htp1_id); end
  def home_team_player2; Player.first(:id => htp2_id); end
  def home_team_player3; Player.first(:id => htp3_id); end

  property :atp1_id, Integer
  property :atp2_id, Integer
  property :atp3_id, Integer
  def away_team_player1; Player.first(:id => atp1_id); end
  def away_team_player2; Player.first(:id => atp2_id); end
  def away_team_player3; Player.first(:id => atp3_id); end

  # playoff games only
  property :bracket_round, Integer, :default => 0
  property :is_playoff_game, Boolean, :default => false

  # relations
  belongs_to :season
  has n, :rounds
end
