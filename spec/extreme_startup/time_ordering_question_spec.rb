require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe TimeOrderingQuestion do
    let(:question) { TimeOrderingQuestion.new(Player.new) }

    it "converts to a string" do
      question.as_text.should =~ /which of the following is earliest: .+/i
    end

  end
end
