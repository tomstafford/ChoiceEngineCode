require_relative 'link'
require_relative 'post'
require_relative 'interaction'

module ChoiceEngine
  class Responder

    def initialize(message, username)
      @message = message.strip
      @username = username
      @content_base_url = ENV.fetch('CONTENT_BASE_URL')
    end

    def respond
      DatabaseConfig.make_normal_connection
      new_post = get_post_for_message

      if new_post
        Interaction.create(username: @username, post_id: new_post.id)
        "#{new_post.description} #{next_options(new_post)} #{content_url(new_post)}"
      else
        p "Bot didn't understand the message '#{@message}'"
        "I didn't understand your message '#{@message}'"
      end
    end

    private

    def content_url(post)
      "#{@content_base_url}#{post.url}"
    end

    def get_post_for_message
      if @message.include?('START')
        Post.where(start: true).sample
      else
        last_post_for_user = Interaction.latest_post_for(@username)
        if last_post_for_user
          p 'We have last post for user, so find the next one'
          find_next_step_actual(@message, last_post_for_user.id)
        else
          p 'We cannot find the last post for user, so pick random one based on message'
          find_next_step_random(@message)
        end
      end
    end

    def next_options(current_post)
      current_post.links.pluck(:abbreviation).join(',')
    end

    def find_next_step_random(abbreviation, current_post_id = nil)
      link = Link.where("abbreviation LIKE ?", "%#{abbreviation}%").sample
      return unless link
      link.outgoing_post
    end

    def find_next_step_actual(abbreviation, current_post_id)
      link = Link.find_by("abbreviation LIKE ? AND post_id = ?", "%#{abbreviation}%", current_post_id)
      return unless link
      link.outgoing_post
    end
  end
end
