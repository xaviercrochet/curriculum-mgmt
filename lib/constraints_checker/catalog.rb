module ConstraintsChecker
  class Catalog
    attr_accessor :courses
    attr_accessor :p_modules
    attr_accessor :sub_modules
    attr_accessor :logs

    def initialize()
      self.courses = {}
      self.p_modules = {}
      self.sub_modules = {}
      self.logs = {prerequisites_missing: [], corequisites_missing: [], prerequisites_not_passet: []}
    end

    def find_p_module(id)
      p "searching course <"+id.to_s+">"
      if self.p_modules[id].nil?
        p "PModule not found :-/"
      end
      self.p_modules[id]
    end

    def add_course(course)
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
      logs = @logs
      courses.each do |key, value|
        if ! value.nil?
          p value.to_s
          logs = build_logs(logs, value.check) 
        end
      end
      return logs
    end

  private
    def build_logs(logs, new_data)
      new_data.each do |element|
        element.each do |key, value|
          logs[key] = logs[key] + value
        end
      end
      return logs
    end
  end
end