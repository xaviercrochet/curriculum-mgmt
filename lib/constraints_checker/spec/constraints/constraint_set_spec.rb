require 'constraints/constraint_set'
require 'catalog'
require 'entities/course'

describe ConstraintsChecker::Constraints::ConstraintSet do
  it "test constraint set" do
    catalog1 = ConstraintsChecker::Catalog.new(id: 1, name: "catalog1")
    catalog2 = ConstraintsChecker::Catalog.new(id: 2, name: "catalog2")

    c1 = ConstraintsChecker::Entities::Course.new(name: "course1", id: "1")
    c2 = ConstraintsChecker::Entities::Course.new(name: "course2", id: "2")
    c3 = ConstraintsChecker::Entities::Course.new(name: "course3", id: "3")
    
    catalog1.add_childrens([c1, c2, c3])
    constraint_set1 = ConstraintsChecker::Constraints::OrCorequisite.new(c1, [c2.id, c3.id])
    c1.add_constraint(constraint_set1)
    p "coucou - "+catalog1.courses.size.to_s
    p "children size " + c1.childrens.size.to_s
    expect(c1.constraints.size).to be == 1
    expect(c2.constraints.size).to be == 0
    expect(c3.constraints.size).to be == 0
    expect(catalog1.check).to be == []
    catalog2.add_childrens([c1, c2])
    expect(catalog2.check).to be == [{:or_corequisites_missing=>["3"]}]
    #expect(catalog1.check).to be ==  {:or_corequisites_missing=>[], :prerequisites_missing=>[], :corequisites_missing=>[], :prerequisites_not_passed=>[]}
  end
end


