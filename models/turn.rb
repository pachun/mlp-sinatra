class Turn
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :started_at, DateTime

  # semi-relations
  property :round_id, Integer
  property :team_id, Integer

  # general
  property :playable, Boolean, :default => true # for balls back

  # relations
  has n, :shots
end
