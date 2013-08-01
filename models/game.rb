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
  property :ref_id, Integer
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

  def self.new_with(info)
    game_info = info[:game]
    requester = Player.first(:api_key => info[:requester_api_key])
    return false if game_info.nil? || requester.nil? || game_info[:season_id].to_i == 0
    season = Season.first(:id => game_info[:season_id].to_i)
    return false if season.league.commissioner_id != requester.id
    new_game = Game.create(:scheduled_time => game_info[:scheduled_time],
                :home_team_id => game_info[:home_team_id].to_i,
                :away_team_id => game_info[:away_team_id].to_i,
                :season_id => game_info[:season_id].to_i
               )
    new_game.save
  end

  def bundle_details
    rounds.map do |round|
      round.bundle
    end.to_json
  end

  def score(info)
    self.winning_team_id = info[:winning_team_id].to_i
    self.was_played = true
    self.ref_id = info['ref_id'].to_i
    self.home_team_id = info['home_team_id'].to_i
    self.away_team_id = info['away_team_id'].to_i
    self.htp1_id = info['htp1_id'].to_i
    self.htp2_id = info['htp2_id'].to_i
    self.atp1_id = info['atp1_id'].to_i
    self.atp2_id = info['atp2_id'].to_i
    if self.season.league.players_per_team == 3
      self.htp3_id = info['htp3_id'].to_i
      self.atp3_id = info['atp3_id'].to_i
    end
    info['rounds'].each do |round_json|
      round_json['game_id'] = self.id
      Round.new_with(round_json)
    end
    save
  end
end
