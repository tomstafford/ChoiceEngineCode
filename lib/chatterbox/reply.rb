require_relative '../database_config.rb'

# MONKEY PATCH
# this block responds to mentions of your bot
module Chatterbot
  #
  # handle checking for mentions of the bot
  module Reply
    # handle replies for the bot
    def replies(&_block)
      return unless require_login

      DatabaseConfig.make_normal_connection

      last_reply_id = ChoiceEngine::LastId.first.last_reply_id
      p '#' * 80
      p 'Chatterbot reply'
      pp "Check for replies since this last id -  #{last_reply_id} on #{ChoiceEngine::LastId.first.updated_at}"

      opts = {}
      opts[:since_id] = last_reply_id unless last_reply_id.nil?
      opts[:count] = 200

      results = client.mentions_timeline(opts)

      @current_tweet = nil

      max_reply_id = last_reply_id || 1071498426544766977

      results.each do |s|
        if s.id > max_reply_id
          max_reply_id = s.id
        end
        @current_tweet = s
        yield s
      end

      pp 'Update last reply id with that last reply id'
      ChoiceEngine::LastId.first.update(last_reply_id: max_reply_id)
      p '#' * 80
      pp
      @current_tweet = nil
    end
  end
end
