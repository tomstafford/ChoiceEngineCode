require 'spec_helper'
require_relative '../../../../lib/choice_engine/activerecord_models/post.rb'
require_relative '../../../../lib/choice_engine/activerecord_models/link.rb'

module ChoiceEngine
  describe ChoiceEngine::Post do
    let!(:incoming_post) { Post.create(title: 'incoming post') }
    let(:link_1_abbreviation) { 'AA POST' }
    let(:link_2_abbreviation) { 'BB post' }
    let!(:outgoing_post) { Post.create(title: 'A') }
    let!(:outgoing_post_2) { Post.create(title: 'B') }
    let!(:link_1) { Link.create(post: incoming_post, outgoing_post: outgoing_post, abbreviation: link_1_abbreviation) }
    let!(:link_2) { Link.create(post: incoming_post, outgoing_post: outgoing_post_2, abbreviation: link_2_abbreviation) }

    it 'simple test for latest post' do
      expect(incoming_post.next_options).to eq "#{link_1_abbreviation}, #{link_2_abbreviation}"
    end
  end
end
