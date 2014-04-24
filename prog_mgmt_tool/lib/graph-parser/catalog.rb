module GraphParser
  class Catalog

    attr_accessor :p_modules
    attr_accessor :courses
    attr_accessor :programs
    
    def initialize
      @p_modules = {}
      @courses = {}
      @programs = {}
    end

    def add_p_module(id, p_module)
      @p_modules[id] = p_module
    end

    def add_course(id, course)
      @courses[id] = course
    end

    def add_program(id, program)
      @programs[id] = program
    end

    def print
      @programs.each do |pp|
        pp.print
      end
      @p_module.each do |pm|
        pm.print
      end

      @courses.each do |c|
        c.print
      end
    end


  end
end