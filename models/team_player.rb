class TeamPlayer
  include DataMapper::Resource

  # meta
  property :id, Serial

  # general
  property :accepted_invite, Boolean, :default => false
  property :accepted_at, DateTime

  # relations
  belongs_to :team
  belongs_to :player
end
