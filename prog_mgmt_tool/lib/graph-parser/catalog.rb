require 'entities/course'
require 'entities/program'
require 'entities/p_module'
require 'entity'

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

    def count_courses
      result = @courses.size
      @programs.each do |key, value|
        result = result + value.count_courses
      end

      @p_modules.each do |key, value|
        result = result + value.count_courses
      end

      return result

    end

    def count_p_modules
      result = @p_modules.size
      @p_modules.each do |key, value|
        result = result + value.count_p_modules
      end

      @programs.each do |key, value|
        result = result + value.count_p_modules
      end
      return result
    end

    def print
      @programs.each do |key, value|
        value.print
      end
      @p_modules.each do |key, value|
        value.print
      end

      @courses.each do |key, value|
        value.print
      end
    end


  end
end