class Round
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :started_at, DateTime

  # general
  property :number, Integer
  def first_turn; Turn.first(:round_id => self.id, :first_of_round => true); end
  def second_turn; Turn.first(:round_id => self.id, :first_of_round => false); end

  # relations
  belongs_to :game

  def bundle
    bundled = {
      :id => self.id,
      :started_at => self.started_at,
      :number => self.number,
      :first_turn => first_turn.bundle,
    }
    bundled[:second_turn] = second_turn.bundle unless second_turn.nil?
    bundled
  end

  def self.new_with(info)
    round = Round.new
    round.game_id = info['game_id'].to_i
    round.started_at = info['started_at']
    round.number = info['number'].to_i

    round.save
    first_turn_json = info['first_turn']
    first_turn_json['round_id'] = round.id
    first_turn_json['first_of_round'] = true
    Turn.new_with(first_turn_json)

    second_turn_json = info['second_turn']
    unless second_turn_json['shots'].nil?
      second_turn_json['round_id'] = round.id
      second_turn_json['first_of_round'] = false
      Turn.new_with(second_turn_json)
    end

    round
  end
end
