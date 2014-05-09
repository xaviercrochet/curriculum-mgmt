module constraints_checker
  module entities
    class SubModule < Entity
      attr_accessor :p_module
      attr_accessor :course_ids

      def initialize(id, name, catalog, courses, p_module)
        super(id, name, catalog) 
        self.courses = courses 
        self.p_module = p_module
      end
    end
  end
end