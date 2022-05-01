=begin
def initialize(player)
  @player = player
end
=end

def get_secret_word
    # get word between 5 and 12 characters long for the secret word.
    words = []
    dictionary = File.join('google-10000-english-no-swears.txt')
    File.readlines(dictionary).each do |line|
        words << line unless line.size < 5 && line.size > 12
    end
    rand_index = rand(5..words.size)
    @secret_word = words[rand_index]
end

def check_letter(letter)
    # get a letter from user and check if it is in the secret word
    matching = []
    @secret_word.split('').each_with_index { |l, idx| matching << idx if l == letter.downcase }
    matching
end

puts get_secret_word
puts 'First try: '
p check_letter(gets.chomp)