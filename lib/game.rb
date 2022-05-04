require_relative 'hangman'
require 'json'

def save_game(current_game)
  Dir.mkdir('saved') unless Dir.exist?('saved')
  filename = "saved/#{current_game['player']}.json"
  File.open(filename, 'w') do |file|
    file.puts current_game.to_json
  end
  filename
end

def choose_saved_game
  saved_games = Dir.entries('saved')
  saved_games[2..saved_games.size].each_with_index { |filename, idx| puts "#{idx}: #{filename}" }
  choose_file = gets.chomp.to_i
  saved_games[choose_file + 2]
end

def load_game(filename)
  loaded_game = File.read("saved/#{filename}")
  JSON.parse(loaded_game)
end

print 'Type 0 to start a new game, or 1 to load a game: '
choice = gets.chomp.to_i
if choice.zero?
  print "Let's play Hangman! What's your name? "
  game = Hangman.new(gets.chomp)
  print 'Type 0 to play with english words or 1 to play with portuguese words: '
  lang = gets.chomp
  filename = if lang.to_i.zero?
               'google-10000-english-no-swears.txt'
             else
               'portuguese_words.txt'
             end
  game.secret_word(filename)
  game.set_board
else
  puts 'Choose from saved games: '
  filename = choose_saved_game
  loaded_game = load_game(filename)
  game = Hangman.new(loaded_game['player'])
  game.set_loaded_game(loaded_game)
end

n = 1
while game.end_game == 3
  #system 'clear'

  game.current_board
  print "#{n} try. Insert a letter: "
  input = game.valid_input(gets.chomp.downcase)
  next if input.nil?

  game.check_letter(input)
  n += 1
  filename = save_game(game.current_game)
end

File.delete(filename) if File.exist?(filename)
system 'clear'
game.current_board
