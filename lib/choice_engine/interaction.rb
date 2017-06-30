require 'active_record'

module ChoiceEngine
  class Interaction < ActiveRecord::Base
    belongs_to :post

    def self.latest_post_for(username)
      where(username: username).order(created_at: :desc).limit(1).first.post
    end
  end
end
