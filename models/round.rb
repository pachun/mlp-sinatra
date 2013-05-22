class Round
  include DataMapper::Resource

  # meta
  property :id, Seral
  property :started_at, DateTime, :default => Time.now

  # general
  property :number, Integer
  property :first_turn_id, Integer
  property :second_turn_id, Integer

  # relations
  belongs_to :game
end
