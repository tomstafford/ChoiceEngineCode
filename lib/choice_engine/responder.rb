module ChoiceEngine
  class Responder

    def initialize(message)
      @message = message
    end

    def respond
      @message.reverse
    end
  end
end
