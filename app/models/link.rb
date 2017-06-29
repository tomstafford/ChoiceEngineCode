class Link < ActiveRecord::Base
  belongs_to :post
  belongs_to :outgoing_post, :class_name => "Post", :foreign_key => "outgoing_post_id"
  belongs_to :extension
end
