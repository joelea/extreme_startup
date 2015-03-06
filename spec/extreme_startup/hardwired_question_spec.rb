require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe HardWiredQuestion do
    let(:question) { HardWiredQuestion.new(Player.new, "question text", "answer") }

    it "should have the correct text" do
      question.as_text.should eql "question text"
    end

    it "should identify the correct answer" do
      question.answered_correctly?("answer").should be_true
    end

    it "should identify a wrong answer" do
      question.answered_correctly?("not the answer").should be_false
    end
  end
end