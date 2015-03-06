require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe ElementsSumToZeroQuestion do

    let(:question) { ElementsSumToZeroQuestion.new(Player.new, [-1, 3, 2, 4, -5, 1]) }

    it "should convert to the full question" do
      question.as_text.should =~ /Find 2 elements that sum to 0 in: -1, 3, 2, 4, -5, 1/
    end

    it "should identify a correct answer pair" do
      question.answered_correctly?("1, -1").should be_true
    end

    it "should reject an answer pair that is not in a valid list" do
      question.answered_correctly?("1").should be_false
    end

    it "should reject an answer pair that has more than 2 elements" do
      question.answered_correctly?("1, -1, 3").should be_false
    end

    it "should reject an answer containing non-number values in the list" do
      question.answered_correctly?("1, abba").should be_false
    end

    it "should only accept numbers that are in the original list" do
      question.answered_correctly?("2, -2").should be_false
    end

  end
end