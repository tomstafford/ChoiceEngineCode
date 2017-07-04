module ChoiceEngine
  class Utils

    UN1 = "@choiceengine".freeze
    UN2 = "@ChoiceEngine".freeze
    UN3 = "@Choiceengine".freeze
    USER_NAMES = [ UN1, UN2, UN3 ]

    def self.remove_username_from_text(text)
      text = text.dup if text.frozen?
      text.slice! UN1
      text.slice! UN2
      text.slice! UN3
      text
    end
  end
end
