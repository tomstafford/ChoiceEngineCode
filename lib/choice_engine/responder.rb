require_relative 'link'
require_relative 'post'
require_relative 'interaction'
require 'textacular'

module ChoiceEngine
  class Responder

    def initialize(message, username)
      @message = message.strip
      @username = username
      @content_base_url = ENV.fetch('CONTENT_BASE_URL')
    end

    def respond
      DatabaseConfig.make_normal_connection

      if @message.include?('RESET')
        p "Reset and clear ready to start again"
        Interaction.where(username: @username).delete_all
      else
        new_post = get_post_for_message

        if new_post
          p "New post received, create interaction"
          Interaction.create(username: @username, post_id: new_post.id)
          "#{new_post.description} #{new_post.next_options} #{content_url(new_post)}"
        else
          p "Bot didn't understand the message '#{@message}'"
          "I didn't understand your message or where you are from: '#{@message}'"
        end
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
          p "We have last post for user #{@username}, so find the next step"
          find_next_step_for(@message, last_post_for_user.id)
        end
      end
    end

    def find_next_step_for(abbreviation, current_post_id)
      link = Link.fuzzy_search(abbreviation: abbreviation).where(post_id: current_post_id)
      return unless link.any?
      link.first.outgoing_post
    end
  end
end
