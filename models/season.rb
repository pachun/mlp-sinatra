class Season
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String, :length => 2..20
  property :teams_locked, Boolean, :default => false

  # relations
  belongs_to :league
  has n, :teams
  has n, :games

  # create
  def self.new_with(info)
    season_info = info[:season]
    league = League.first(:id => season_info[:league_id].to_i)
    requester = Player.first(:api_key => info[:requester_api_key])
    return false if !league
    return false if requester.id != league.commissioner_id.to_i

    season = Season.create(:name => season_info[:name],
                           :league_id => season_info[:league_id].to_i)
    season.save

    {:id => season.id, :created_at => season.created_at, :teams_locked => season.teams_locked}
  end

  # get all the teams
  def self.teams(info)
    player = Player.first(:api_key => info[:requester_api_key])
    season = Season.first(:id => info[:season_id].to_i)
    return false if player.nil? || season.nil?
    return false if player.id != season.league.commissioner.id

    season.teams_with_players
  end

  # bundle season teams with their players
  def teams_with_players
    teams.map do |team|
      {
        :id => team.id,
        :name => team.name,
        :num_players => league.players_per_team,
        :finalized => team.finalized,
        :finalized_at => team.finalized_at,
        :proposed_at => team.proposed_at,
      }
    end
  end
end
