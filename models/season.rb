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

  def self.new_with(info)
    season_info = info[:season]
    league = League.first(:id => season_info[:league_id].to_i)
    requester = Player.first(:api_key => info[:requester_api_key])
    return false if !league || league.commissioner_id != requester.id
    season = Season.create(:name => season_info[:name], :league_id => season_info[:league_id].to_i)
    season.save
    {:id => season.id, :created_at => season.created_at, :teams_locked => season.teams_locked}
  end

  def self.teams(info)
    requester = Player.first(:api_key => info[:requester_api_key])
    season = Season.first(:id => info[:season_id].to_i)
    return false if requester.nil? || season.nil?
    return false if !season.league.players.map{|p| p.id}.include?(requester.id)
    season.teams
  end
end
