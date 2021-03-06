require_relative 'activerecord_models/link'
require_relative 'activerecord_models/post'
require_relative 'activerecord_models/interaction'
require_relative '../database_config.rb'

# Used by fuzzy search below
require 'textacular'

module ChoiceEngine
  class Responder
    def initialize(incoming_message, from_username)
      @incoming_message = incoming_message.strip
      @from_username = from_username
      @content_base_url = ENV.fetch('CONTENT_BASE_URL')
    end

    def response
      DatabaseConfig.make_normal_connection

      if @incoming_message.include?('RESET')
        p "Reset and clear ready to start again"
        Interaction.where(username: @from_username).delete_all
      end

      new_post = new_message_based_on_last_one
      new_post_id = nil

      response = if new_post
                   p "New post received, create interaction"
                   new_post_id = new_post.id
                   get_response(new_post)
                 end
      p "responding with: #{response}"
      [response, new_post_id]
    end

  private

    def get_response(new_post)
      "#{new_post.description} #{content_url(new_post)} options are: #{new_post.next_options}"
    end

    def content_url(post)
      "#{@content_base_url}#{post.url}"
    end

    def new_message_based_on_last_one
      if @incoming_message.upcase.include?('START') || @incoming_message.upcase.include?('RESET')
        Post.where(start: true).sample
      else
        last_post_for_user = Interaction.latest_post_for(@from_username)
        if last_post_for_user
          p "We have last post for user #{@from_username}, so find the next step"
          find_next_step_for(@incoming_message, last_post_for_user.id)
        end
      end
    end

    # JJ why are we not using current post id?
    def find_next_step_for(abbreviation, _current_post_id)
      link = Link.fuzzy_search(abbreviation: abbreviation.upcase)
      return unless link.any?

      link.first.outgoing_post
    end
  end
end
