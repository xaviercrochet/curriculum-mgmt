module ConstraintsChecker
	class Constraint
    attr_accessor :logs

		def initialize
      @logs = []
		end

		def check
			return True
		end
	end
end