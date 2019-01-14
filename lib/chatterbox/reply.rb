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
      pp "check for replies since this twitter id - #{ChoiceEngine::LastId.first.updated_at} last reply id #{last_reply_id}"

      opts = {}
      opts[:since_id] = last_reply_id unless last_reply_id.nil?
      opts[:count] = 200

      results = client.mentions_timeline(opts)

      @current_tweet = nil

      max_reply_id = last_reply_id || 1071498426544766977

      results.each { |s|
        if s.id > max_reply_id
          max_reply_id = s.id
        end
        @current_tweet = s
        yield s
      }
      ChoiceEngine::LastId.first.update(last_reply_id: max_reply_id)
      @current_tweet = nil
    end
  end
end
