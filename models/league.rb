class League
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String, :required => true
  property :commissioner_id, Integer, :required => true
  property :current_season_id, Integer, :default => 0, :required => true

  # league rules
  property :players_per_team, Integer, :default => 2, :required => true
  property :plays_balls_back, Boolean, :default => false, :required => true
  property :extra_point_cups, String, :default => '', :required => true
  property :rerack_cups, String, :default => '3,6', :required => true

  # relations
  has n, :seasons

  has n, :league_players
  has n, :players, :through => :league_players

  # create a new league with the given attributes and commissioner's api_key
  def self.new_with(info)
    player = Player.first(:api_key => info[:commissioner_key])
    return false if player.nil?

    league_info = info[:league]
    league_info[:commissioner_id] = player.id
    new_league = League.create(league_info)

    new_league.save
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
  def self.invite_player(info)
    league = League.first(:id => info[:league_id])
    invitee = Player.first(:id => info[:player_id])
    commissioner = Player.first(:api_key => info[:commissioner_key])
    return false if league.nil? || invitee.nil? || commissioner.nil?
    return false if league.commissioner_id != commissioner.id

    invite = LeaguePlayer.create(:league_id => league.id, :player_id => invitee.id)
    invite.save
  end
end
