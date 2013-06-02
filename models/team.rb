class Team
  include DataMapper::Resource

  # meta
  property :id, Serial

  # general
  property :name, String, :length => 2..20
  property :finalized, Boolean, :default => false
  property :proposed_at, DateTime, :default => Time.now
  property :finalized_at, DateTime

  # player info
  property :p1_id, Integer
  property :p2_id, Integer
  property :p3_id, Integer

  def player1; Player.first(:id => p1_id); end
  def player2; Player.first(:id => p2_id); end
  def player3; Player.first(:id => p3_id); end

  property :p1_accepted, Boolean, :default => true
  property :p2_accepted, Boolean, :default => false
  property :p3_accepted, Boolean, :default => false

  # playoff info
  property :playoff_seat, Integer, :default => 0
  property :eliminated, Boolean, :default => false

  # relations
  belongs_to :season
end
