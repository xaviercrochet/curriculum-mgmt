module constraints_checker
  class Catalog
    attr_accessor :courses
    attr_accessor :p_modules
    attr_accessor :sub_modules

    def initialize()
      self.courses = {}
      self.p_modules = {}
      self.sub_modules = {}
    end

    def find_p_module(id)
      p "searching course <"+id.to_s+">"
      if self.p_modules[id].nil?
        p "PModule not found :-/"
      end
      self.p_modules[id]
    end

    def add_course(course)
      p "Adding course ..."
      self.courses[course.id] = course
    end

    def add_p_module(p_module_id)
      self.p_modules[p_module_id]
    end

    def find_course(id)
      p "seach course <"+id.to_s+">"
      if self.courses[id].nil?
        p "Course not found :-/"
      end
      self.courses[id]
    end

    def check
      logs = []
      p "#of courses : "+courses.size.to_s
      courses.each do |key, value|
        if ! value.nil?
          logs << value.check 
        end
      end
      logs.flatten!
    end
  end
end