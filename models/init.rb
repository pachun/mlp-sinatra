require 'data_mapper'
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/mlp.db")

require_relative 'league_player'
require_relative 'team_player'
require_relative 'team_game'

require_relative 'player'

require_relative 'league'

require_relative 'team'

require_relative 'game'

require_relative 'season'
require_relative 'round'
require_relative 'turn'
require_relative 'shot'

DataMapper.finalize
DataMapper.auto_upgrade!
