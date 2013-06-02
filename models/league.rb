class League
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String, :length => 2..20
  property :commissioner_id, Integer
  property :current_season_id, Integer, :default => 0
  def commissioner; Player.first(:id => commissioner_id); end

  # rules
  property :players_per_team, Integer, :default => 2
  property :plays_balls_back, Boolean, :default => false
  property :extra_point_cups, String, :default => ''
  property :rerack_cups, String, :default => '4,7'

  # relations
  has n, :seasons

  has n, :league_players
  has n, :players, :through => :league_players

  def self.new_with(info)
    league = info[:league]
    league[:commissioner_id] = league[:commissioner_id].to_i
    league[:players_per_team] = league[:players_per_team].to_i
    commissioner = Player.first(:id => league[:commissioner_id])
    return false if commissioner.nil? || commissioner.api_key != info[:requester_api_key]

    new_league = League.create(league)
    new_league.save
    LeaguePlayer.create({
      :league_id => new_league.id,
      :player_id => commissioner.id,
      :is_referee => true,
      :accepted_invite => true,
      :accepted_at => Time.now
    }).save
    new_league
  end

  def self.invite(info)
    league = League.first(:id => info[:league_id].to_i)
    invitee = Player.first(:id => info[:player_id].to_i)
    requester = Player.first(:api_key => info[:requester_api_key])
    return false if league.nil? || invitee.nil? || requester.nil?
    return false if league.commissioner_id != requester.id

    invite = LeaguePlayer.create(:league_id => league.id, :player_id => invitee.id)
    invite.save
  end

  def self.invitable_players(info)
    league = League.first(:id => info[:league_id].to_i)
    return false if league.commissioner.api_key != info[:requester_api_key]

    Player.all(:order => [:name.asc]).map do |player|
      player_info = {:id => player.id, :name => player.name}
      invite = LeaguePlayer.first(:league_id => league.id, :player_id => player.id)
      if invite
        player_info[:invited] = true
        player_info[:accepted_invite] = invite.accepted_invite
      else
        player_info[:invited] = false
        player_info[:accepted_invite] = false
      end
      player_info
    end
  end

  def self.update(info)
    league_info = info[:league]
    requester = Player.first(:api_key => info[:requester_api_key])
    league = League.first(:id => info[:league_id].to_i)
    return false if league.nil?
    return false if requester.id != league.commissioner_id
    updated = true
    updated = updated && league.update(:current_season_id => league_info[:current_season_id].to_i) if league_info.has_key?('current_season_id')
    # updated = updated && new_update_here
    updated
  end

  def self.players(info)
    requester = Player.first(:api_key => info[:requester_api_key])
    league = League.first(:id => info[:league_id].to_i)
    return false if requester.nil? || league.nil?
    return false if !requester.leagues.map{|l| l.id}.include?(league.id)
    enrolled_players = league.players.select do |p|
      LeaguePlayer.first(:player_id => p.id, :league_id => league.id).accepted_invite
    end
    enrolled_players.map { |p| Player.sanitize(p) }
  end

  def self.with_commissioner(l)
    {
      :id => l.id,
      :created_at => l.created_at,
      :name => l.name,
      :commissioner => Player.sanitize(Player.first(:id => l.commissioner_id)),
      :current_season_id => l.current_season_id,
      :players_per_team => l.players_per_team,
      :plays_balls_back => l.plays_balls_back,
      :extra_point_cups => l.extra_point_cups,
      :rerack_cups => l.rerack_cups
    }
  end

  def self.with_commissioner_and_season(l)
    {
      :id => l.id,
      :created_at => l.created_at,
      :name => l.name,
      :commissioner => Player.sanitize(Player.first(:id => l.commissioner_id)),
      :current_season => Season.first(:id => l.current_season_id),
      :players_per_team => l.players_per_team,
      :plays_balls_back => l.plays_balls_back,
      :extra_point_cups => l.extra_point_cups,
      :rerack_cups => l.rerack_cups
    }
  end
end
