module constraints_checker
  module entities
    class PModule < Entity
      def initialize(id, name, catalog)
        super(id, name, catalog)
      end

      def add_course(course)
        courses[course.id] = course
      end

      def find_course(course_id)
        p "searching course <"+course_id.to_s+">"
        if courses[course_id].nil?
          p "Course not found :-/"
        end
        courses[course_id]
      end

      def count_credits
        credits = 0
        self.sub_modues.each do |m|
          credits = credits + m.count_credits.to_i
        end
        self.courses.each do |c|
          credits = credits + c.credits.to_i unless c.credits.eql? 'NONE'
        end
        credits
      end

      def check_min(value)
        self.count_credits >= value
      end

      def check_max(value)
        self.count_credits <= value
      end
    end
  end
end