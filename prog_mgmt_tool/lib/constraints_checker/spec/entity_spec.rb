require_relative '../constraints_checker'
require_relative '../entities/entity'

describe ConstraintsChecker::Entities::Course do
	it "Course Test" do
		ConstraintsChecker::Entities::Course.new("caca", "caca", "caca").should be_an_instance_of ConstraintsChecker::Entities::Course
	end
end