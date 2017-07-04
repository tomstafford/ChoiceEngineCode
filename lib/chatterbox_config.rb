#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'

# Enabling **debug_mode** prevents the bot from actually sending
# tweets. Keep this active while you are developing your bot. Once you
# are ready to send out tweets, you can remove this line.
# debug_mode

# Chatterbot will keep track of the most recent tweets your bot has
# handled so you don't need to worry about that yourself. While
# testing, you can use the **no_update** directive to prevent
# chatterbot from updating those values. This directive can also be
# handy if you are doing something advanced where you want to track
# which tweet you saw last on your own.
no_update if ENV.key?('NO_UPDATE')

# remove this to get less output when running your bot
verbose

# The blocklist is a list of users that your bot will never interact
# with. Chatterbot will discard any tweets involving these users.
# Simply add their twitter handle to this list.
#blocklist "abc", "def"

# Here's a list of words to exclude from searches. Use this list to
# add words which your bot should ignore for whatever reason.
#exclude "hi", "spammer", "junk"

# Exclude a list of offensive, vulgar, 'bad' words. This list is
# populated from Darius Kazemi's wordfilter module
# @see https://github.com/dariusk/wordfilter
exclude bad_words

#
# Specifying 'use_streaming' will cause Chatterbot to use Twitter's
# Streaming API. Your bot will run constantly, listening for tweets.
# Alternatively, you can run your bot as a cron/scheduled job. In that
# case, do not use this line. Every time you run your bot, it will
# execute once, and then exit.
#
use_streaming if ENV.key?('USE_STREAMING')
