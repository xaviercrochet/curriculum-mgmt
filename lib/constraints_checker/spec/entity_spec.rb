require 'entity'
require 'entities/course'
require 'constraint'

describe ConstraintsChecker::Entity do
	



	it "Entity Test" do
		parent = ConstraintsChecker::Entity.new(name: "Parent")
		entity = ConstraintsChecker::Entity.new(name: "Entity", id: "42")
		
		parent.add_children(entity)
		
		expect(entity.parent.name).to include "Parent"
		expect(entity.name).to include "Entity"
		expect(entity.id).to include "42"
		expect(parent.childrens.size).to be == 1

		course1 = ConstraintsChecker::Entities::Course.new(name: "LINGI4242", credits: "4", id: "1")
		course2 = ConstraintsChecker::Entities::Course.new(name: "SINF4242", credits: "6", id: "2")
		course3 = ConstraintsChecker::Entities::Course.new(name: "SINF4243", id: "3")

		constraint1 = ConstraintsChecker::Constraint.new
		constraint2 = ConstraintsChecker::Constraint.new
		constraint3 = ConstraintsChecker::Constraint.new

		entity.add_children(course1)
		entity.add_childrens([course2, course3])
		entity.add_constraint(constraint1)
		entity.add_constraints([constraint3, constraint2])


		expect(course1.find_course(course3.id).id).to be == course3.id
		expect(course1.find_course(course1.id).id).to be == course1.id
		expect(course1.find_course(entity.id)).to be_nil
		expect(entity.childrens.size).to be == 3
		expect(entity.constraints.size).to be == 3
		expect(entity.count_credits).to be == 10
		# ConstraintsChecker::Entities::Course.new(0, "caca", "caca", "caca", "caca").should be_an_instance_of ConstraintsChecker::Entities::Course
		# catalog = ConstraintsChecker::Entities::Catalog.new
		# course1 = ConstraintsChecker::Entities::Course.new(0, "test", catalog, "", "")
		# course2 = ConstraintsChecker::Entities::Course.new(1, "test2", catalog, "", "")
		# catalog.add_course(course1)
		# course1.passed = false
		# catalog.add_course(course2)
		# constraint1 = ConstraintsChecker::Constraints::Prerequisite.new(course1, course2)
		# course2.add_constraint(constraint1)
		# p constraint1.check.to_s
		# p catalog.check
		# course3 = ConstraintsChecker::Entities::Course.new(2, "test3", "", "", "")
	end
end