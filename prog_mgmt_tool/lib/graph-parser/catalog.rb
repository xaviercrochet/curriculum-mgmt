require 'entities/course'
require 'entities/program'
require 'entities/p_module'
require 'entity'

module GraphParser
  class Catalog

    attr_accessor :p_modules
    attr_accessor :courses
    attr_accessor :programs
    attr_accessor :constraint_sets
    
    def initialize
      @p_modules = []
      @courses = []
      @programs = []
      @constraint_sets = []
    end

    def add_p_module(p_module)
      @p_modules << p_module
    end

    def add_constraint_set(constraint_set)
      @constraint_sets << constraint_set
    end

    def find_course(id)
      result = nil
      @courses.each do |c|
        if c.id.eql? id
          return c
        end
      end
    end

    def find_constraint_set(id)
      result = nil
      @constraint_sets.each do |c|
        if c.id.eql? id
          return c
        end
      end
    end

    def add_course(course)
      @courses << course
    end

    def add_program(program)
      @programs << program
    end

    def count_courses
      return @courses.size
    end

    def count_p_modules
      result = @p_modules.size
      @p_modules.each do |m|
        result = result + m.count_p_modules
      end

      @programs.each do |m|
        result = result + m.count_p_modules
      end
      return result
    end

    def print
      @programs.each do |m|
        m.print
      end
      @p_modules.each do |m|
        m.print
      end

      @courses.each do |m|
        m.print
      end
    end


  end
end