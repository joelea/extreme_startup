require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe QuestionFactory do
    let(:player)  { Player.new("player one") }
    let(:factory) { QuestionFactory.new }

    context "in the second round" do
      before(:each) do
        factory.advance_round
      end

       it "creates four different types of question" do
          questions = 20.times.map { factory.next_question(player) }
          questions.group_by { |q| q.class}
                   .size
                   .should eql(4)
      end
    end

    context "in the third round" do
      before(:each) do
        factory.advance_round
        factory.advance_round
      end

       it "moves a sliding window forward, keeping 5 question types, so AdditionQuestions no longer appear" do
        questions = 30.times.map { factory.next_question(player) }
        questions.group_by { |q| q.class}
                 .size
                 .should eql(5)
        end

    end

  end
end
