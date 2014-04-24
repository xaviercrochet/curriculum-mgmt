require 'entities/course'

module GraphParser
  class Constraint
    attr_accessor :source
    attr_accessor :destination
    attr_accessor :type

    def initialize(source, destination, type)
      @source = source
      @destination = destination
      @type = type
    end
  end
end