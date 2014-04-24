module GraphParser
  class Catalog

    attr_accessor :p_modules
    attr_accessor :courses
    
    def initialize
      @p_modules = {}
      @courses = {}
    end

    def add_p_module(id, p_module)
      @p_modules[id] = p_module
    end

    def add_course(id, course)
      @courses[id] = course
    end


  end
end