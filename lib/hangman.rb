require 'erb'

class Hangman
  def initialize(player)
    @player = player.capitalize
    @chances = 7
    @used_letters = []
  end

  def secret_word
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
    input if input.match?(/\A[a-z]*\z/) && input.size == 1 && !@used_letters.include?(input)
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
    puts "Congrats #{@player}, you are the master of dictionaries!! :)" if end_game == 1
    puts "Sorry #{@player}, you are dead :(" if end_game == 2
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

  def current_game
    { 'player' => @player, 'secret_word' => @secret_word, 'board' => @board, 'remaining_chances' => @chances,
      'used_letters' => @used_letters }
  end

  def set_loaded_game(loaded_game)
    @secret_word = loaded_game['secret_word']
    @board = loaded_game['board']
    @chances = loaded_game['remaining_chances']
    @used_letters = loaded_game['used_letters']
  end
end
