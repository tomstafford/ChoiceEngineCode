require_relative 'link'
require_relative 'post'

module ChoiceEngine
  class Responder

    def initialize(message)
      @message = message.strip
    end

    def respond
      new_post = get_post_for_message
      if new_post
        "#{new_post.description} #{next_options(new_post)}"
      else
        @message.reverse
      end
    end

    private

    def get_post_for_message
      if @message.include?('START')
        Post.where(start: true).sample
      else
        find_next_step_random(@message)
      end
    end

    def next_options(current_post)
      current_post.links.pluck(:abbreviation)
    end

    def find_next_step_random(abbreviation, current_post_id = nil)
      Post.links.where("abbreviation LIKE ?", "%#{abbreviation}%").sample
    end

    def find_next_step_actual(abbreviation, current_post_id)
      Post.links.find_by("abbreviation LIKE ? AND post_id = ?", "%#{abbreviation}%", current_post_id)
    end
  end
end
