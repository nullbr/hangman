require_relative 'hangman'
require 'yaml'

def save_game(game, filename)
  Dir.mkdir('saved') unless Dir.exist?('saved')
  dumpfile = YAML.dump(game)
  File.write(filename, dumpfile)
end

# Choose from saved games, return filename if exists, return nil if it does not
def choose_saved_game
  puts 'Getting saved games...'
  options = []
  if Dir.exist?('saved') && Dir.entries('saved').size > 2
    puts 'Choose from saved games: '
    saved_games = Dir.entries('saved')[2..-1]
  else
    puts 'There are no saved games'
    return
  end

  saved_games.each_with_index do |filename, idx|
    puts "#{idx}: #{filename}"
    options << idx
  end
  choose_file = yield(options)
  saved_games[choose_file]
end

def load_game(filename)
  loaded_game = File.read("saved/#{filename}")
  JSON.parse(loaded_game)
end

def get_input(options = ' ')
  yield if block_given?
  while true
    input = gets.chomp.strip
    if %w[quit end exit].include?(input.downcase)
      abort('Exiting the game...')

    # Check if theres only letters in the string if options are string
    elsif options == ' ' && input.match?(/^[[:alpha:]]+$/)
      break

    # Check if string only contains an integer and its the correct type
    elsif !(options == ' ') && input !~ /\D/
      input = input.to_i
      options.include?(input) ? break : (print "Options are #{options} ")

    # Ask for a valid input type
    else
      print "Enter a valid #{options[0].class}. "
    end
  end
  input
end

if Dir.exist?('saved') && Dir.entries('saved').size > 2
  print 'Type 0 to start a new game, or 1 to load a game: '
  choice = get_input([0, 1])
else
  choice = 0
end

# Initializing new game
puts "Let's play Hangman!"

if choice.zero?
  name = get_input { print "What's your name? " }
  game = Hangman.new(name)

  # Set new file to be used for saving the game
  time = Time.now.strftime('%Hh%M-%d-%m-%Y')
  filename = "saved/#{name}-#{time}.json"

  # Choose from the desired dictionary
  print 'Type 0 to play with english words or 1 to play with portuguese words: '
  lang = get_input([0, 1]) { print 'Type 0 to play with english words or 1 to play with portuguese words: ' }
  dictionary = lang.zero? ? 'google-10000-english-no-swears.txt' : 'portuguese_words.txt'
  game.secret_word(dictionary)
  game.set_board
else
  filename = choose_saved_game { |options| get_input(options) }
  loaded_game = load_game(filename)
  game = Hangman.new(loaded_game['player'])
  game.set_loaded_game(loaded_game)
end

n = 1
while game.end_game == 3
  #system 'clear'

  game.current_board
  print "Try number #{n}. Insert a letter: "
  input = get_input
  input = game.valid_input(input)
  next if input.nil?

  game.check_letter(input)
  n += 1
  save_game(game, filename)
end

File.delete(filename) if File.exist?(filename)
system 'clear'
game.current_board
