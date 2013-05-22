# {league/player} join table
class LeaguePlayer
  include DataMapper::Resource

  # meta
  property :id, Serial

  # general
  property :is_referee, Boolean, :default => false

  # invitation info
  property :accepted_invite, Boolean, :default => false
  property :invited_at, DateTime, :default => Time.now
  property :accepted_at, DateTime

  # relations
  belongs_to :league
  belongs_to :player
end
