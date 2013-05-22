class Shot
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :shot_at, DateTime, :default => Time.now

  # general
  property :cup_number, Integer, :default => 0

  # relations
  belongs_to :turn
  belongs_to :player
end
