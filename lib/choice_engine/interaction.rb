require 'active_record'

module ChoiceEngine
  class Interaction < ActiveRecord::Base
    belongs_to :post

    def self.latest_post_for(username)
      latest_posts = where(username: username).order(created_at: :desc).limit(1)
      latest_posts.first.post if latest_posts
    end
  end
end
