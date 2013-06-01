# {team/game} join table
class TeamGame
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :home_team, Boolean

  # relations
  belongs_to :season

  belongs_to :team
  belongs_to :game
end
