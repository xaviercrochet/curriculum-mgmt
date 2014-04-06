require_relative '../constraints_checker'
require_relative '../entities/entity'
require_relative '../constraints/constraint'

describe ConstraintsChecker::Entities::Course do
	it "Course Test" do
		ConstraintsChecker::Entities::Course.new(0, "caca", "caca", "caca", "caca").should be_an_instance_of ConstraintsChecker::Entities::Course
		catalog = ConstraintsChecker::Entities::Catalog.new
		course1 = ConstraintsChecker::Entities::Course.new(0, "test", catalog, "", "")
		course2 = ConstraintsChecker::Entities::Course.new(1, "test2", catalog, "", "")
		catalog.add_course(course1)
		course1.passed = true
		catalog.add_course(course2)
		constraint1 = ConstraintsChecker::Constraints::Prerequisite.new(course1, course2)
		course2.add_constraint(constraint1)
		p constraint1.check.to_s
		course3 = ConstraintsChecker::Entities::Course.new(2, "test3", "", "", "")
	end
end