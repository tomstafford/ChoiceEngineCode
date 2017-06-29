require 'active_record'

module ChoiceEngine
  class Post < ActiveRecord::Base
    has_many :links

    enum importance: [ :high, :medium, :low ]
  end
end
