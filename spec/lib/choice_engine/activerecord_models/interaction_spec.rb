require 'spec_helper'
require_relative '../../../../lib/choice_engine/activerecord_models/interaction.rb'
require_relative '../../../../lib/choice_engine/activerecord_models/post.rb'

module ChoiceEngine
  describe ChoiceEngine::Interaction do
    let!(:post)                 { Post.create(title: 'test1', start: true) }
    let(:username)              { 'username' }
    let(:username_no_posts)     { 'username_no_posts' }
    let!(:old_interaction)      { Interaction.create(username: username, post: post, created_at: Date.parse('2018-01-01')) }
    let!(:interaction)          { Interaction.create(username: username, post: post) }
    let!(:interaction_no_posts) { Interaction.create(username: username_no_posts) }

    it 'simple test for latest post' do
      expect(Interaction.latest_post_for(username)).to eq post
    end

    it 'simple test for latest post' do
      expect(Interaction.latest_post_for(username_no_posts)).to eq nil
    end
  end
end
