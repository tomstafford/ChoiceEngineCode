require 'rubygems'
require 'dotenv'

require_relative 'choice_engine/responder.rb'
require_relative 'choice_engine/utils.rb'

Dotenv.load('../.env')

require_relative 'chatterbox_config'
# Overriding chatterboxes reply
require_relative 'chatterbox/reply.rb'

ARRAY_OF_ACTIONS = %i(tweet wait wait wait wait wait wait wait wait wait wait wait reply reply reply reply reply reply reply reply reply reply reply reply).freeze

UPTIME_MESSAGES = [
"The Choice Engine is an interactive essay about the psychology, neuroscience and philosophy of free will. Follow and reply START to begin.",
"The Choice Engine is brought to you by: @tomstafford - Words; @J_o_n_C_a_n - Design; @jamesjefferies - Code; A @FestivalMind project.",
"I don't respond to replies immediately. Sometimes it can take a few hours, but I will get to yours soon. Make sure you are following to ensure you see replies.",
"Reply with RESET to clear your history",
"Twitter sometimes hides my replies. Please follow me to ensure you see replies to your messages (if you have 'quality filter' ticked in Settings > Notifications you may not be notified of my replies). More on this here https://tomstafford.github.io/choice-engine-text/teething.",
"Make sure you are following to ensure you see replies.",
"'I cannot persuade myself that a beneficent & omnipotent God would have designedly created the Ichneumonidae with the express intention of their feeding within ... living bodies': Charles Darwin https://www.asa3.org/ASA/PSCF/2001/PSCF9-01Miles.html",
"Watch Richard Dawkins explain the experiments with the digger wasp in the 1991 Royal Institution Christmas Lectures https://youtu.be/qm-0Z0ceezQ?t=2m30s",
"'That it’s you and no one else that owns / That spot that yer standing, that space that you’re sitting'. http://www.bobdylan.com/songs/last-thoughts-woody-guthrie/",
"Your choices are free because they are yours, not because they are independent of you or other structures in the world",
"'Rule 30 is a one-dimensional binary cellular automaton rule introduced by Stephen Wolfram in 1983. Using Wolfram's classification scheme, Rule 30 is a Class III rule, displaying aperiodic, chaotic behaviour' https://en.wikipedia.org/wiki/Rule_30",
"Play Conway's Game of Life https://playgameoflife.com/",
"Each choice is made by us, and so it feels that it could have been made otherwise. We can’t avoid choosing, and we are compelled to believe that this choosing matters.",
"Things happen for a reason, but surely we are not mere things!",
"'Calvinism but no Hobbes' by Luke Surl http://www.lukesurl.com/archives/comic/280-calvinism-but-no-hobbes",
"'A parasitic wasp has injected her eggs into a caterpillar -- and now they're ready to hatch. ' National Geographic https://www.youtube.com/watch?v=vMG-LWyNcAs",
"Research Digest: Contrary to popular psychological theory, believers in free will were no more generous or honest https://digest.bps.org.uk/2018/08/20/contrary-to-popular-psychological-theory-believers-in-free-will-were-no-more-generous-or-honest/",
"Choice Engine will not settle the riddle of free will, but it does map out some paths through the woods. Some things that worry people about free will shouldn’t. Some apparent contradictions aren’t. ",
"Finding out more about neuroscience doesn’t diminish our responsibilities, or our selves.",
"Choice Engine is about the neuroscience of free will, about our intuitions about freedom and choice, and about complex systems and what they can teach us about the first two things.",
"Our choices are free because they are ours, not because they are independent of the universe. ",
"Our choices arise from the bit of the universe which we occupy - our history, our brains, our thoughts. This is what makes them unique, personal, unpredictable.",
"They're made out of meat https://mindhacks.com/2011/07/07/theyre-made-out-of-meat/",
"Mind and Brain are different sides of the same thing, like a bicycle has wheels but it can also have a speed and direction. ",
"When something affects your mind your brain is changed. Thoughts and feelings, arguments and reasons, all have a physical reality in your brain meat.",
"Recommended: Descartes' Baby: How the Science of Child Development Explains What Makes Us Human by Paul Bloom https://www.goodreads.com/book/show/225880.Descartes_Baby",
"Recommended:  The Illusion of Conscious Will By Daniel M. Wegner https://mitpress.mit.edu/books/illusion-conscious-will",
"Research Digest: Neuroscience does not threaten people’s sense of free will https://digest.bps.org.uk/2014/09/23/neuroscience-does-not-threaten-peoples-sense-of-free-will/",
"Schurger et al (2012) An accumulator model for spontaneous neural activity prior to self-initiated movement http://www.pnas.org/content/109/42/E2904/1",
"Report on Libet's original experiment on the neuroscience of free will, Libet et al (1983) https://academic.oup.com/brain/article-abstract/106/3/623/271932",
"Dennett (2006) The Self as a Responding—and Responsible—Artifact https://nyaspubs.onlinelibrary.wiley.com/doi/full/10.1196/annals.1279.003",
"Using fMRI to repeat the Libet experiments: Soon et al (2008). Unconscious determinants of free decisions in the human brain https://www.nature.com/articles/nn.2112",
"Mindhacks.com: Critical strategies for free will experiments https://mindhacks.com/2015/08/07/critical-strategies-for-free-will-experiments/",
"Frith & Haggard (2018). Volition and the Brain – Revisiting a Classic Experimental Study https://www.cell.com/trends/neurosciences/fulltext/S0166-2236(18)30112-7",
"BBC Future: Why do we intuitively believe we have free will http://www.bbc.com/future/story/20150806-why-your-intuitions-about-the-brain-are-wrong",
"Recommended: “Elbow Room” by Daniel Dennett https://en.wikipedia.org/wiki/Elbow_Room_(book)",
"Recommended: “Godel Escher Bach” by Douglas Hofstader https://en.wikipedia.org/wiki/G%C3%B6del,_Escher,_Bach",
"Recommended: “Chaos” by James Gleik https://en.wikipedia.org/wiki/Chaos:_Making_a_New_Science",
"Recommended: Gilbert Ryle’s (1949) “The Concept of Mind”. https://en.wikipedia.org/wiki/The_Concept_of_Mind",
"Recommended: Roy Porter’s “Flesh in the Age of Reason” https://www.goodreads.com/book/show/479533.Flesh_in_the_Age_of_Reason",
"Mitchell (2018): Does Neuroscience Leave Room for Free Will https://www.sciencedirect.com/science/article/pii/S0166223618301553",
"Explorable on cellular automata https://spaciecat.github.io/cells/",
"Devin Acker's Simple 1D Wolfram cellular automaton using HTML5/JS http://devinacker.github.io/celldemo/",
"Stephen Wolfram's blog about the design of Cambridge Train Station http://blog.stephenwolfram.com/2017/06/oh-my-gosh-its-covered-in-rule-30s/",
"Lucas Oman's cellular automata demo http://lucasoman.com/files/projects/caeditor/caed.php",
"Fabienne Serrière makes computational knitwear https://twitter.com/knityak",
"Greene & Cohen (2004). For the law, neuroscience changes nothing and everything. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1693457/",
"For argument's sake: evidence that reason can change minds https://www.amazon.co.uk/arguments-sake-evidence-reason-change-ebook/dp/B010O1Z018",
"NEW RESEARCH: For whom does determinism undermine moral responsibility? Surveying the conditions for free will across cultures https://psyarxiv.com/j248d/",
"Video: Great Golden Digger Wasp burying a paralyzed grasshopper https://www.youtube.com/watch?v=5t2p4ukzL74"
].freeze

#<Twitter::SearchResults:0x00007fb09eacd338
 # @attrs=
 #  {:statuses=>[],
 #   :search_metadata=>
 #    {:completed_in=>0.022,
 #     :max_id=>1035261852706643968,
#

module ChoiceEngine
  class Runner
    def self.run
      action = what_to_do_this_time?

      if action == :reply
        reply_action
      elsif action == :tweet
        tweet_action
      end
    end

    def self.reply_action
      # Update last since check in case we have no replies, we search for a
      last_id = client.search("a", since: Date.today.strftime('%Y-%m-%d')).attrs[:search_metadata][:max_id]
      ChoiceEngine::Utils::update_last_id(last_id)

      # These replies come from chatterbot, everything in this block gets run per tweet
      replies do |tweet|
        if tweet.user.screen_name == ENV['TWITTER_USER_NAME']
          p "Don't reply to yourself: #{tweet.text}"
        else
          reply_to_tweet(tweet)
        end
      end
    end

    def self.reply_to_tweet(tweet)
      # We need to check this tweet still exists
      # We should follow if we don't already
      p ' ' * 80
      p '#' * 80
      p 'Reply to tweet'
      user_screen_name = tweet.user.screen_name
      pp "We have received Tweet id #{tweet.id} from this user name: #{user_screen_name}"
      ChoiceEngine::Utils.follow_if_we_do_not(tweet.user.id)

      text = ChoiceEngine::Utils.remove_username_from_text(tweet.text)
      response, new_post_id = ChoiceEngine::Responder.new(text, user_screen_name).response

      if response
        # Reply using Twitter API wrapped in chatterbot
        client_response = client.update("@#{user_screen_name} #{response}", in_reply_to_status_id: tweet.id)
        # pp client_response.url
        pp client_response.inspect
        ChoiceEngine::Utils.create_interaction(user_screen_name, new_post_id, client_response.url)
      else
        p "Not responding, didn't understand #{tweet.text}"
      end
      p 'Reply to tweet'
      p '#' * 80
      p ' ' * 80
    end

    def self.tweet_action
      # Uses chatterbot tweet method
      tweet get_random_tweet_message
    end

    def self.get_random_tweet_message
      UPTIME_MESSAGES.sample + " (#{Time.now.utc})"
    end

    def self.what_to_do_this_time?
      if ENV['ENVIRONMENT'] == 'development' || ENV['ENVIRONMENT'] == 'test'
        p "Reply immediately as we are in development or test mode"
        return :reply
      end
      ARRAY_OF_ACTIONS.sample
    end
  end
end
