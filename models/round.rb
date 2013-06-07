class Round
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :started_at, DateTime

  # general
  property :number, Integer
  property :first_turn_id, Integer
  property :second_turn_id, Integer

  # relations
  belongs_to :game
end
