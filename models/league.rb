class League
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String, :length => 2..20
  property :commissioner_id, Integer
  property :current_season_id, Integer, :default => 0

  # league rules
  property :players_per_team, Integer, :default => 2
  property :plays_balls_back, Boolean, :default => false
  property :extra_point_cups, String, :default => ''
  property :rerack_cups, String, :default => '4,7'

  # relations
  has n, :seasons

  has n, :league_players
  has n, :players, :through => :league_players

  # create a new league with the given attributes and commissioner's api_key
  def self.new_with(league, api_key)
    league[:commissioner_id] = league[:commissioner_id].to_i
    league[:players_per_team] = league[:players_per_team].to_i

    player = Player.first(:id => league[:commissioner_id])
    return false if player.nil?
    return false if player.api_key != api_key

    new_league = League.create(league)
    new_league.save

    LeaguePlayer.create({
      :league_id => new_league.id,
      :player_id => player.id,
      :is_referee => true,
      :accepted_invite => true,
      :accepted_at => Time.now
    }).save

    new_league
  end

  # add a referee
  def self.add_referee(info)
    league = League.first(:id => info[:league_id])
    new_ref = Player.first(:id => info[:player_id])
    commissioner = Player.first(:api_key => info[:commissioner_key])
    return 'missing info' if league.nil? || new_ref.nil? || commissioner.nil?
    return 'no permission' if league.commissioner_id != commissioner.id

    league_player = LeaguePlayer.first(:league_id => league.id, :player_id => new_ref.id, :accepted_invite => true)
    return 'player not in league' if league_player.nil?

    if league_player.update(:is_referee => true)
      'updated'
    else
      'failed'
    end
  end

  # update the league
  def self.update_with(info)
    league = League.first(:id => info[:league_id])
    commissioner = Player.first(:api_key => info[:commissioner_key])
    league_info = info[:league_changes]

    return false if league.commissioner_id != commissioner.id

    # only allow updating these attributes of the league
    league_info.select! { |a| a == :name || a == :commissioner_id || a == :current_season }
    return league.update(league_info)
  end

  # invite a player
  def self.invite(info)
    league = League.first(:id => info[:league_id].to_i)
    invitee = Player.first(:id => info[:player_id].to_i)
    requester = Player.first(:api_key => info[:requester_api_key])
    return false if league.nil? || invitee.nil? || requester.nil?
    return false if league.commissioner_id != requester.id

    invite = LeaguePlayer.create(:league_id => league.id, :player_id => invitee.id)
    invite.save
  end

  # get a list of players in & out of the league
  def self.invitable_players(league_id, requester_api_key)
    league = League.first(:id => league_id)
    commissioner = Player.first(:id => league.commissioner_id)

    return false if commissioner.api_key != requester_api_key

    all_players = Player.all(:order => [:full_name.asc])

    invitable_players = []
    all_players.each do |player|
      player_info = {:id => player.id, :name => player.full_name}

      invite = LeaguePlayer.first(:league_id => league.id, :player_id => player.id)
      if invite
        player_info[:invited] = true
        player_info[:accepted_invite] = invite.accepted_invite
      else
        player_info[:invited] = false
        player_info[:accepted_invite] = false
      end
      invitable_players << player_info
    end

    invitable_players
  end
end
