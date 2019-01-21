require 'spec_helper'
require_relative '../../../../lib/choice_engine/activerecord_models/interaction.rb'

module ChoiceEngine
  describe ChoiceEngine::Interaction do
    subject { Interaction.new(username: 'username', post_id: 1) }

    it 'simple test' do
      expect(subject).to be_valid
    end
  end
end
