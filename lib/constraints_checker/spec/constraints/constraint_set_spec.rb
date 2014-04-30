require 'constraints/constraint_set'
require 'catalog'
require 'entities/course'

describe ConstraintsChecker::Constraints::ConstraintSet do
  it "test constraint set" do
    catalog1 = ConstraintsChecker::Catalog.new
    catalog2 = ConstraintsChecker::Catalog.new

    c1 = ConstraintsChecker::Entities::Course.new(name: "course1", id: "1")
    c2 = ConstraintsChecker::Entities::Course.new(name: "course2", id: "2")
    c3 = ConstraintsChecker::Entities::Course.new(name: "course3", id: "3")
    
    catalog1.add_course(c1)
    catalog1.add_course(c2)
    catalog1.add_course(c3)

    constraint_set1 = ConstraintsChecker::Constraints::OrCorequisite.new(c1, [c2.id, c3.id])
    c1.add_constraint(constraint_set1)


    expect(catalog1.check).to be ==  {:or_corequisites_missing=>[], :prerequisites_missing=>[], :corequisites_missing=>[], :prerequisites_not_passed=>[]}
  end
end


