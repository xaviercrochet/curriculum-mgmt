module GraphParser
  module Entities
    class ConstraintSet
      attr_accessor :sources
      attr_accessor :destinations
      attr_accessor :type
      attr_accessor :set_type
      attr_accessor :id
      attr_accessor :node

      def initialize(id, set_type)
        @id = id
        @set_type = set_type
        @destinations = []
        @sources = []
      end

      def add_source(source)
        @sources << source
      end

      def add_destination(destination)
        @destinations << destination
      end

    end
  end
end