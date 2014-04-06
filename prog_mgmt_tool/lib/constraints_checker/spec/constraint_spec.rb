require_relative '../constraints/constraint'
require_relative '../constraints_checker'

describe ConstraintsChecker::Constraints::Prerequisite do 
	it "Constraint test" do
		ConstraintsChecker::Constraints::Prerequisite.new("test", "test").should be_an_instance_of ConstraintsChecker::Constraints::Prerequisite
	end
end