require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe TimeOrderingQuestion do
    let(:question) { TimeOrderingQuestion.new(Player.new) }


    it "converts to a string" do
      question.as_text.should =~ /which of the following is earliest: \d+[(am)(pm)](, \d+[(am)(pm)])*/i
    end

    describe "when given some times" do
      let(:question) { TimeOrderingQuestion.new(Player.new, [10, 8] , [10, 11]) }

      it "should convert to the full question" do
        question.as_text.should =~ /which of the following is earliest: /i
        question.as_text.should =~ /10am/
        question.as_text.should =~ /8am/
        question.as_text.should =~ /10pm/
        question.as_text.should =~ /11pm/
      end

      it "identifies a correct answer" do
        question.answered_correctly("10am").should be_true
      end
    end
  end
end