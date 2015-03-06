require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe TimeOrderingQuestion do
    let(:question) { TimeOrderingQuestion.new(Player.new) }


    it "converts to a string" do
      question.as_text.should =~ /which of the following is earliest: .+/i
    end

    describe "when given some times" do
      let(:question) { TimeOrderingQuestion.new(Player.new, ["10pm", "11am", "10am", "9pm"])}

      it "should convert to the full question" do
        question.as_text.should =~ /which of the following is earliest: 10pm, 11am, 10am, 9pm/i
      end
    end
  end
end