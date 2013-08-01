class Shot
  include DataMapper::Resource

  # meta
  property :id, Serial
  property :shot_at, DateTime

  # general
  property :status, String
  property :cup_number, Integer, :default => 0

  # relations
  belongs_to :turn
  belongs_to :player

  def bundle
    {
      :id => self.id,
      :shot_at => self.shot_at,
      :status => self.status,
      :cup_number => self.cup_number,
      :player_id => self.player.id
    }
  end

  def self.new_with(info)
    shot = Shot.new
    shot.turn_id = info['turn_id'].to_i
    shot.player_id = info['player_id'].to_i
    shot.status = info['status']
    shot.cup_number = info['cup_number'].to_i
    shot.shot_at = info['shot_at']
    shot.save
    shot
  end
end
