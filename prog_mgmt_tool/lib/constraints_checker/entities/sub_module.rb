module constraints_checker
  module entities
    class SubModule < Entity
      attr_accessor :p_module
      attr_accessor :courses

      def initialize(id, name, catalog, courses, p_module)
        super(id, name, catalog) 
        self.courses = courses 
        self.p_module = p_module
      end

      def count_credits
        credits = 0
        self.courses.each do |c|
          credits = credits + c.credits.to_i unless c.credits.eql? 'NONE'
        end
        credits
      end

      def check_min(value)
        count_credits >= value
      end

      def check_max(value)
        count_credits <= value
      end
    end
  end
end