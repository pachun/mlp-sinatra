class Turn
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :started_at, DateTime

  property :first_of_round, Boolean

  # semi-relations
  property :round_id, Integer
  property :team_id, Integer

  # relations
  has n, :shots

  def bundle
    {
      :id => self.id,
      :started_at => self.started_at,
      :first_of_round => self.first_of_round,
      :team_id => self.team_id,
      :shots => shots.map {|s| s.bundle},
    }
  end

  def self.new_with(info)
    turn = Turn.new
    turn.started_at = info['started_at']
    turn.first_of_round = info['first_of_round']
    turn.round_id = info['round_id'].to_i
    turn.team_id = info['team_id'].to_i
    if turn.save
      info['shots'].each do |shot|
        shot['turn_id'] = turn.id
        Shot.new_with(shot)
      end
    end
    turn
  end
end
