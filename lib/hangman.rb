require 'erb'

class Hangman
  def initialize(player)
    @player = player
    @chances = 7
    @used_letters = []
  end

  def get_secret_word
    # get word between 5 and 12 characters long for the secret word.
    words = []
    dictionary = File.join('google-10000-english-no-swears.txt')
    File.readlines(dictionary).each do |line|
      line = line.tr("\n", '')
      words << line if line.size >= 5 && line.size <= 12
    end
    rand_index = rand(0..words.size)
    @secret_word = words[rand_index].tr("\n", '')
  end

  def set_board
    @board = '____________'[1..@secret_word.size]
  end

  def valid_input(input)
    # return the clean input if it is valid, nil otherwise
    input = input.lstrip
    # check if theres only letters
    if input.match?(/\A[a-z]*\z/) && input.size == 1
      input
    end
  end

  def check_letter(letter)
    # get a letter from user and check if it is in the secret word
    hit = false
    @used_letters << letter
    @secret_word.split('').each_with_index do |l, idx|
      if l == letter
        @board[idx] = l
        hit = true
      end
    end
    @chances -= 1 if hit == false
  end

  def current_board
    corpse_template = File.read('corpse.erb')
    corpse = ERB.new corpse_template
    puts corpse.result(binding)
    # show secret at the end of the game
    if @chances.zero?
      puts @secret_word
    else
      puts @board
    end
    puts "Letters used so far: #{@used_letters.join(', ')}"
    puts "You have #{@chances} chances left"
  end

  def end_game
    # check if board is complete
    if @board.match?(/\A[a-z]*\z/)
      1
    # check if user is out of chances
    elsif @chances.zero?
      2
    # game not done
    else
      3
    end
  end
end

print "Let's play Hangman! What's your name? "
game = Hangman.new(gets.chomp)
game.get_secret_word
game.set_board

n = 1
while game.end_game == 3
  system 'clear'
  game.current_board
  print "#{n} try. Insert a letter: "
  input = game.valid_input(gets.chomp.downcase)
  next if input.nil?

  p input
  game.check_letter(input)
  n += 1
end

puts game.get_secret_word
game.current_board
