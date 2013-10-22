class Team
  include DataMapper::Resource

  # meta
  property :id, Serial

  # general
  property :name, String, :length => 2..20
  property :wins, Integer, :default => 0
  property :losses, Integer, :default => 0
  property :finalized_at, DateTime
  property :proposed_at, DateTime, :default => Time.now

  # player info
  property :p1_id, Integer
  property :p2_id, Integer
  property :p3_id, Integer

  def player1; Player.first(:id => p1_id); end
  def player2; Player.first(:id => p2_id); end
  def player3; Player.first(:id => p3_id); end

  property :p1_accepted, Boolean, :default => true
  property :p2_accepted, Boolean, :default => false
  property :p3_accepted, Boolean, :default => false

  property :p1_responded, Boolean, :default => true
  property :p2_responded, Boolean, :default => false
  property :p3_responded, Boolean, :default => false

  # playoff info
  property :playoff_seat, Integer, :default => 0
  property :eliminated, Boolean, :default => false

  # relations
  belongs_to :season

  def self.new_with(info)
    team_info = info[:team]
    season = Season.first(:id => team_info[:season_id].to_i)
    return false if season.nil? || season.teams_locked

    requester = Player.first(:api_key => info[:requester_api_key])
    player1 = Player.first(:id => team_info[:p1_id].to_i)
    player2 = Player.first(:id => team_info[:p2_id].to_i)

    return false if requester.nil?
    return false if player1.nil? || !season.league.includes?(player1)
    return false if player2.nil? || !season.league.includes?(player2)
    return false if player1.id != requester.id

    if season.league.players_per_team == 3
      player3 = Player.first(:id => team_info[:p3_id].to_i)
      return false if player3.nil? || !season.league.includes?(player3)
    else
      team_info.delete('p3_id')
    end

    team_info[:season_id] = team_info[:season_id].to_i
    team_info[:p1_id] = team_info[:p1_id].to_i
    team_info[:p2_id] = team_info[:p2_id].to_i
    team_info[:p3_id] = team_info[:p3_id].to_i if season.league.players_per_team == 3
    team = Team.create(team_info)
    team.save
    team
  end

  def includes?(player)
    if season.league.players_per_team == 3
      p1_id == player.id || p2_id == player.id || p3_id == player.id
    else
      p1_id == player.id || p2_id == player.id
    end
  end

  def attempt_finalization
    if season.league.players_per_team == 3
      update(:finalized_at => Time.now) if p1_responded && p2_responded && p3_responded
    else
      update(:finalized_at => Time.now) if p1_responded && p2_responded
    end
  end

  # def wins
  #   season = Season.first(:id => self.season_id)
  #   season.games.all(:winning_team_id => self.id).count
  # end

  # def losses
  #   season = Season.first(:id => self.season_id)
  #   games = season.games.all(:home_team_id => self.id)
  #   games += season.games.all(:away_team_id => self.id)
  #   games.count - wins
  # end
end
