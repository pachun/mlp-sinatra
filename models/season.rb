class Season
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :created_at, DateTime, :default => Time.now

  # general
  property :name, String
  property :teams_locked, Boolean, :default => false

  # relations
  belongs_to :league
  has n, :teams
  has n, :games
end
