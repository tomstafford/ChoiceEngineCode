require 'active_record'

module ChoiceEngine
  class Interaction < ActiveRecord::Base
    belongs_to :post

    def self.latest_post_for(username)
      lastest_posts = where(username: username).order(created_at: :desc).limit(1)
      lastest_posts.first.post if latest_posts
    end
  end
end
