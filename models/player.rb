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

  def self.sanitize(player, league)
    current_season = league.seasons.first(:id => league.current_season_id)
    {
      :id => player.id,
      :name => player.name,
      :email => player.email,
      :registered_at => player.registered_at,
      :lpp => player.lpp(league),
      :lhp => player.lhp(league),
      :spp => player.spp(current_season),
      :shp => player.shp(current_season),
      :llc => player.llc(league),
      :slc => player.slc(current_season),
    }
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

  def self.invited_leagues(info)
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

  def self.invited_teams(info)
    requester = Player.first(:api_key => info[:requester_api_key])
    player = Player.first(:id => info[:player_id].to_i)
    season = Season.first(:id => info[:season_id].to_i)
    return false if requester.nil? || player.nil? || season.nil?
    return false if requester.id != player.id
    return false if !season.league.includes?(player)

    Team.all(:season_id => season.id, :p1_id => player.id, :order => [:proposed_at.desc]) +
    Team.all(:season_id => season.id, :p2_id => player.id, :order => [:proposed_at.desc]) +
    Team.all(:season_id => season.id, :p3_id => player.id, :order => [:proposed_at.desc])
  end

  def self.team_invite(response, info)
    requester = Player.first(:api_key => info[:requester_api_key])
    player = Player.first(:id => info[:player_id].to_i)
    team = Team.first(:id => info[:team_id].to_i)
    return false if requester.nil? || player.nil? || team.nil?
    return false if requester.id != player.id
    return false if !team.includes?(player)

    if player.id == team.p1_id
      team.update(:p1_responded => true, :p1_accepted => (response == :accept))
    elsif player.id == team.p2_id
      team.update(:p2_responded => true, :p2_accepted => (response == :accept))
    elsif team.season.league.players_per_team == 3 && player.id == team.p3_id
      team.update(:p3_responded => true, :p3_accepted => (response == :accept))
    end
    team.attempt_finalization
    true
  end

  def lpp(league)
    shots = shots_in_league(league)
    return 0 if shots.count == 0
    points = point_percentage(league, shots)
    (points / shots.count).to_s.to_f.round(2)
  end

  def lhp(league)
    shots = shots_in_league(league)
    return 0 if shots.count == 0
    hits = shots.select{ |shot| shot.cup_number > 0 && shot.status != 'no_shot' }
    (hits.count.to_f / shots.count).round(2)
  end

  def spp(season)
    shots = shots_in_season(season)
    return 0 if shots.count == 0
    points = point_percentage(season.league, shots)
    (points / shots.count).to_s.to_f.round(2)
  end

  def shp(season)
    shots = shots_in_season(season)
    return 0 if shots.count == 0
    hits = shots.select{ |shot| shot.cup_number > 0 && shot.status != 'no_shot' }
    (hits.count.to_f / shots.count).round(2)
  end

  def llc(league)
    shots = shots_in_league(league)
    shots.select{ |shot| shot.cup_number == 10 }.count
  end

  def slc(season)
    shots = shots_in_season(season)
    shots.select{ |shot| shot.cup_number == 10 }.count
  end

  def point_percentage(league, shots)
    specials = league.extra_point_cups.split(',').map{ |s| s.to_i }
    points = 0.0
    shots.each do |shot|
      if specials.include?(shot.cup_number) && shot.cup_number == 10
        points += 3
      elsif specials.include?(shot.cup_number)
        points += 2
      elsif shot.status == 'shot' && shot.cup_number > 0
        points += 1
      end
    end
    points
  end

  def shots_in_league(league)
    rounds = []
    league.seasons.each do |season|
      rounds += season.games.all(:winning_team_id.not => nil).rounds
    end
    shots_in_rounds(rounds)
  end

  def shots_in_season(season)
    rounds = season.games.all(:winning_team_id.not => nil).rounds
    shots_in_rounds(rounds)
  end

  def shots_in_rounds(rounds)
    shots = []
    rounds.each do |round|
      shot = round.first_turn.shots.first(:player_id => self.id)
      shots << shot unless shot.nil? || shot.status == 'no_shot'
      unless round.second_turn.nil?
        shot = round.second_turn.shots.first(:player_id => self.id)
        shots << shot unless shot.nil? || shot.status == 'no_shot'
      end
    end
    shots
  end
end
