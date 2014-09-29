require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe QuestionFactory do
    let(:player)  { Player.new("player one") }
    let(:factory) { QuestionFactory.new }

    context "in the first round" do
       it "creates both AdditionQuestions and SquareCubeQuestion" do
          questions = 10.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.all? { |q| [AdditionQuestion, MaximumQuestion].include? q.class }
        end
    end

    context "in the second round" do
      before(:each) do
        factory.advance_round
      end

       it "creates four different types of question" do
          questions = 20.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.all? { |q| [AdditionQuestion, MaximumQuestion, MultiplicationQuestion, SquareCubeQuestion, ].include? q.class }
        end

    end

    context "in the third round" do
      before(:each) do
        factory.advance_round
        factory.advance_round
      end

       it "moves a sliding window forward, keeping 5 question types, so AdditionQuestions no longer appear" do
          questions = 30.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_false
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.all? { |q| [MaximumQuestion, MultiplicationQuestion, SquareCubeQuestion, GeneralKnowledgeQuestion, PrimesQuestion].include? q.class }
        end

    end

    context "in the 8th round" do
      before(:each) do
        7.times { factory.advance_round }
      end

      it "keeps the last window of questions available" do
        questions = 30.times.map { factory.next_question(player) }
        questions.group_by { |q| q.class}
                 .size
                 .should eql(5)
      end

    end

  end
end
