require_relative 'entity'
require_relative 'entities/p_module'
require_relative 'entities/course'
module ConstraintsChecker
  class Catalog < Entity
    attr_accessor :logs

    def initialize(properties)
      super(properties)
      self.logs = {
        or_corequisites_missing: [],
        xor_corequisites_missing: [], 
        or_prerequisites_missing: [], 
        xor_prerequisites_missing: [],  
        prerequisites_missing: [], 
        corequisites_missing: [], 
        prerequisites_not_passed: [],
        to_few_credits: [],
        to_many_credits: [],
        courses_missing_in_module: {},
        mandatory_courses_missing: []
      }
    end

    def find_course(id)
      self.find_children(id, ConstraintsChecker::Entities::Course)
    end

    def find_p_module(id)
      self.find_children(id, ConstraintsChecker::Entities::PModule)
    end


    def find_root
      self
    end

    def check_constraints
      results = check
      results.each do |result|
        result.each do |key, value|
          if value.is_a?(Hash)
            p @logs[key]
            p value
            @logs[key] = @logs[key].merge(value)
          else
            @logs[key] += value
            @logs[key] += value
          end
        end
      end
      return @logs
    end

    # def check
    #   p "catalog check"
    #   logs = @logs
    #   courses.each do |key, value|
    #     if ! value.nil?
    #       logs = build_logs(logs, value.check) 
    #     end
    #   end
    #   return logs
    # end

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