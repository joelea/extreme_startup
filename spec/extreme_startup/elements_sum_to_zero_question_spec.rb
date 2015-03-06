require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe ElementsSumToZeroQuestion do

    let(:question) { ElementsSumToZeroQuestion.new(Player.new, [-1, 3, 2, 4, -5, 1]) }

    it "should convert to the full question" do
      question.as_text.should =~ /Find 2 elements that sum to 0 in: -1, 3, 2, 4, -5, 1/
    end

  end
end