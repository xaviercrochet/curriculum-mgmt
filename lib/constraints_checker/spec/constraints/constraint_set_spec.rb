require 'constraints/constraint_set'
require 'student_program'
require 'entities/course'

describe ConstraintsChecker::Constraints::ConstraintSet do
  it "test constraint set" do
    catalog2 = ConstraintsChecker::StudentProgram.new(id: "5", name: "catalog2")

    c1 = ConstraintsChecker::Entities::Course.new(id: "1", name: "course1", id: "1", start_year: 1)
    c2 = ConstraintsChecker::Entities::Course.new(id: "2", name: "course2", id: "2", start_year: 1)
    c3 = ConstraintsChecker::Entities::Course.new(id: "3", name: "course3", id: "3", start_year: 1)
    
    constraint_set1 = ConstraintsChecker::Constraints::OrCorequisite.new("1", c1, [c2.id, c3.id])
    c1.add_constraint(constraint_set1)
    expect(c1.constraints.size).to be == 1
    expect(c2.constraints.size).to be == 0
    expect(c3.constraints.size).to be == 0
    catalog2.add_children(c1)
    catalog2.add_children(c2)
    expect(c1.parent).not_to be_nil
    expect(c2.parent).not_to be_nil
    expect(c3.parent).to be_nil
    expect(catalog2.check).to be == []
  end
end


