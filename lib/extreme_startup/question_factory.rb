require 'set'
require 'prime'

module ExtremeStartup

  class Time
    attr_reader :twenty_four_hour_representation

    def initialize(twenty_four_hour_representation)
      @twenty_four_hour_representation = twenty_four_hour_representation
    end

    def as_24_hour_time
      @twenty_four_hour_representation.to_s + ".00"
    end

    def as_military_time
      if @twenty_four_hour_representation < 10
        prefix = "0"
      else
        prefix = ""
      end
      prefix + @twenty_four_hour_representation.to_s + "00"
    end

    def as_analogue_time
      if @twenty_four_hour_representation < 12
        return @twenty_four_hour_representation.to_s + "am"
      else
        return (@twenty_four_hour_representation - 12).to_s + "pm"
      end
    end

  end

  class Question
    class << self
      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s[0..7]
      end
    end

    def ask(player)
      url = player.url + '?q=' + URI.escape(self.to_s)
      puts "GET: " + url
      begin
        response = get(url)
        if (response.success?) then
          self.answer = response.to_s
        else
          @problem = "error_response"
        end
      rescue => exception
        puts exception
        @problem = "no_server_response"
      end
    end

    def get(url)
      HTTParty.get(url)
    end

    def result
      if @answer && self.answered_correctly?(answer)
        "correct"
      elsif @answer
        "wrong"
      else
        @problem
      end
    end

    def delay_before_next
      case result
        when "correct"        then 5
        when "wrong"          then 10
        else 20
      end
    end

    def was_answered_correctly
      result == "correct"
    end

    def was_answered_wrongly
      result == "wrong"
    end

    def display_result
      "\tquestion: #{self.to_s}\n\tanswer: #{answer}\n\tresult: #{result}"
    end

    def id
      @id ||= Question.generate_uuid
    end

    def to_s
      "#{id}: #{as_text}"
    end

    def answer=(answer)
      @answer = answer.force_encoding("UTF-8")
    end

    def answer
      @answer && @answer.downcase.strip
    end

    def answered_correctly?(answer)
      correct_answer.to_s.downcase.strip == answer
    end

    def points
      10
    end
  end

  class BinaryMathsQuestion < Question
    def initialize(player, *numbers)
      if numbers.any?
        @n1, @n2 = *numbers
      else
        @n1, @n2 = rand(20), rand(20)
      end
    end
  end

  class ElementsSumToZeroQuestion < Question
    def initialize(player, numbers=nil)
      if numbers.nil?
        numbers = random_number_list
        numbers << -numbers.sample()
        numbers = numbers.shuffle().uniq()
      end

      @numbers = numbers
    end

    def answered_correctly?(numberString)
      begin
        numbers_as_strings = numberString.split(", ")
        answers = numbers_as_strings.map { |n| Integer(n) }
        return (answers.size == 2) &&
               (answers.inject(:+) == 0) &&
               answers.all? { |n| @numbers.include? n }

      rescue
        false
      end
    end

    def as_text
      "Find 2 elements that sum to 0 in: #{@numbers.join(", ")}"
    end

    private

    def random_number_list
      (0..3+rand(7)).map { 50 - rand(100) }
    end
  end

  class HardWiredQuestion < Question
    attr_reader :correct_answer

    def initialize(player, question, answer)
      @question = question
      @correct_answer = answer
    end

    def as_text
      @question
    end

  end

  class RomanNumeralsQuestion < HardWiredQuestion
    attr_reader :number, :numeral

    def initialize(player)
      question_answer_pair = numeral_mapping.to_a.sample()
      @number = question_answer_pair[1]
      @numeral = question_answer_pair[0]

      question = "Convert #{number} into Roman Numerals"
      super(player, question, numeral)
    end
  end


  class EasyRomanNumeralsQuestion < RomanNumeralsQuestion
    def numeral_mapping
      {
        "I" => 1,
        "II" => 2,
        "III" => 3,
        "IV" => 4,
        "V" => 5,
        "VI" => 6,
        "VII" => 7,
        "VIII" => 8,
        "IX" => 9,
        "X" => 10,
        "XI" => 11,
        "XII" => 12,
        "XIII" => 13,
        "XIV" => 14,
        "XV" => 15,
        "XVI" => 16,
        "XVII" => 17,
        "XVIII" => 18,
        "XIX" => 19,
        "XX" => 20,
      }
    end
  end

  class RandomRomanNumeralsQuestion < RomanNumeralsQuestion
    def numeral_mapping
      {
        "CI" => 101,
        "LIII" => 53,
        "LIV" => 54,
        "XXIII" => 23,
        "XXVII" => 27,
        "DCCCVII" => 807,
        "DCV" => 605,
        "DCCXI" => 711,
        "DCCVII" => 707,
        "DCCVI" => 706,
        "DVI" => 506,
        "DXXIV" => 524,
        "MDCCCXIV" => 1814,
        "MDCCCXVII" => 1817,
        "MDCCXVII" => 1717,
      }
    end
  end

  class ReverseRomanNumeralsQuestion < HardWiredQuestion
    def initialize(player)
      normal_roman_numerals_question = EasyRomanNumeralsQuestion.new(player)

      numeral = normal_roman_numerals_question.numeral
      number = normal_roman_numerals_question.number
      question = "What is #{numeral} in decimal"

      super(player, question, number)
    end
  end

  class HardTimeOrderingQuestion < Question
    attr_reader :correct_answer

    def initialize(player)
      @times = random_list_of_times.uniq()
                                   .map { |t| Time.new(t) }
                                   .map { |time| [time, random_representation_of(time)] }
      @correct_answer = @times.sort { |t| t[0].twenty_four_hour_representation }
                              .first()
                              .first()
    end

    def as_text
      time_strings = @times.map { |time| time[1] }
      "which of the following is earliest: #{time_strings.join(", ")}"
    end

    def random_list_of_times
      (0...2+rand(8)).map { 1 + rand(23) }
    end

    def random_representation_of(time)
      [
        time.as_24_hour_time,
        time.as_military_time,
        time.as_analogue_time,
      ].sample()
    end
  end

  class TimeOrderingQuestion < HardTimeOrderingQuestion
    def random_representation_of(time)
      time.as_analogue_time()
    end
  end

  class SelectFromListOfNumbersQuestion < Question
    def initialize(player, *numbers)
      if numbers.any?
        @numbers = *numbers
      else
        size = rand(2)
        @numbers = random_numbers[0..size].concat(candidate_numbers.shuffle[0..size]).shuffle
      end
    end

    def random_numbers
      randoms = Set.new
      loop do
        randoms << rand(1000)
        return randoms.to_a if randoms.size >= 5
      end
    end

    def correct_answer
      @numbers.select do |x|
         should_be_selected(x)
      end.join(', ')
    end
  end

  class AdditionQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2}"
    end
  private
    def correct_answer
      @n1 + @n2
    end
  end

  class SubtractionQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} minus #{@n2}"
    end
  private
    def correct_answer
      @n1 - @n2
    end
  end

  class MultiplicationQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} multiplied by #{@n2}"
    end
  private
    def correct_answer
      @n1 * @n2
    end
  end

  class FibonacciQuestion < BinaryMathsQuestion
    def as_text
      n = @n1 + 4
      if (n > 20 && n % 10 == 1)
        return "what is the #{n}st number in the Fibonacci sequence"
      end
      if (n > 20 && n % 10 == 2)
        return "what is the #{n}nd number in the Fibonacci sequence"
      end
      return "what is the #{n}th number in the Fibonacci sequence"
    end
    def points
      50
    end
  private
    def correct_answer
      n = @n1 + 4
      a, b = 0, 1
      n.times { a, b = b, a + b }
      a
    end
  end

  require 'yaml'
  class AnagramQuestion < Question
    def as_text
      possible_words = [@anagram["correct"]] + @anagram["incorrect"]
      %Q{which of the following is an anagram of "#{@anagram["anagram"]}": #{possible_words.shuffle.join(", ")}}
    end

    def initialize(player, *words)
      if words.any?
        @anagram = {}
        @anagram["anagram"], @anagram["correct"], *@anagram["incorrect"] = words
      else
        anagrams = YAML.load_file(File.join(File.dirname(__FILE__), "anagrams.yaml"))
        @anagram = anagrams.sample
      end
    end

    def correct_answer
      @anagram["correct"]
    end
  end

  class ScrabbleQuestion < Question
    def as_text
      "what is the english scrabble score of #{@word}"
    end

    def initialize(player, word=nil)
      if word
        @word = word
      else
        @word = ["banana", "september", "cloud", "zoo", "ruby", "buzzword"].sample
      end
    end

    def correct_answer
      @word.chars.inject(0) do |score, letter|
        score += scrabble_scores[letter.downcase]
      end
    end

    private

    def scrabble_scores
      scores = {}
      %w{e a i o n r t l s u}.each  {|l| scores[l] = 1 }
      %w{d g}.each                  {|l| scores[l] = 2 }
      %w{b c m p}.each              {|l| scores[l] = 3 }
      %w{f h v w y}.each            {|l| scores[l] = 4 }
      %w{k}.each                    {|l| scores[l] = 5 }
      %w{j x}.each                  {|l| scores[l] = 8 }
      %w{q z}.each                  {|l| scores[l] = 10 }
      scores
    end
  end

  class MaximumQuestion < SelectFromListOfNumbersQuestion
    def as_text
      "which of the following numbers is the largest: " + @numbers.join(', ')
    end
    def points
      40
    end
    private
    def should_be_selected(x)
      x == @numbers.max
    end

    def candidate_numbers
      (1..100).to_a
    end
  end


  class QuestionFactory
    attr_reader :round, :max_round

    def initialize
      @round = 1
      @max_round = 7
      @question_types = [
        AdditionQuestion,
        EasyRomanNumeralsQuestion,
        TimeOrderingQuestion,
        ElementsSumToZeroQuestion,
        FibonacciQuestion,
        MaximumQuestion,
        MultiplicationQuestion,
        ReverseRomanNumeralsQuestion,
        HardTimeOrderingQuestion,
        FibonacciQuestion,
        RandomRomanNumeralsQuestion,
        AnagramQuestion,
        ScrabbleQuestion
      ]
    end

    def next_question(player)
      window_end = (@round * 2 - 1)
      window_start = [0, window_end - 4].max
      available_question_types = @question_types[window_start..window_end]
      available_question_types.sample.new(player)
    end

    def advance_round
      @round = [@round + 1, @max_round].min
    end

  end

  class WarmupQuestion < Question
    def initialize(player)
      @player = player
    end

    def correct_answer
      @player.name
    end

    def as_text
      "what is your name"
    end
  end

  class WarmupQuestionFactory
    def next_question(player)
      WarmupQuestion.new(player)
    end

    def advance_round
      raise("please just restart the server")
    end
  end

end
