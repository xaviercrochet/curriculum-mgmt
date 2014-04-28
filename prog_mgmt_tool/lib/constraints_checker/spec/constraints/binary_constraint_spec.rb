require 'entity'
require 'entities/course'
require 'entities/p_module'
require 'constraints/binary_constraint'

describe ConstraintsChecker::Constraints::BinaryConstraint do 
  it "Check Binary Contraint" do
    course1 = ConstraintsChecker::Entities::Course.new(name: "Coucou", id: '1', passed: true)
    course2 = ConstraintsChecker::Entities::Course.new(name: "salut", id: '2', passed: false)
    course3 = ConstraintsChecker::Entities::Course.new(name: "SINF4242", id: '3')
    course4 = ConstraintsChecker::Entities::Course.new(name: "LINGI4242", id: '4')
    
    c1 = ConstraintsChecker::Constraints::Prerequisite.new(course3, course1.id)
    c2 = ConstraintsChecker::Constraints::Prerequisite.new(course4, course2.id)
    c3 = ConstraintsChecker::Constraints::Corequisite.new(course3, course1.id)
    c4 = ConstraintsChecker::Constraints::Corequisite.new(course3, course2.id)

    p_module1 = ConstraintsChecker::Entities::PModule.new(name: "blabla", id: '42')
    p_module2 = ConstraintsChecker::Entities::PModule.new(name: "coucou", id: '43')

    course3.add_constraints([c1, c3, c4])
    course4.add_constraint(c2)

    expect(course2.passed).to be == false

    expect(course3.constraints.size).to be == 3
    expect(course4.constraints.size).to be == 1

    p_module1.add_childrens([course1, course2, course3])
    p_module2.add_childrens([course4, course2])

    expect(p_module1.childrens.size).to be == 3
    expect(p_module2.childrens.size).to be == 2

    expect(course3.check).to be_empty
    expect(course4.check).to be == [{not_passed: "2"}]

    expect(p_module1.check).to be_empty
    expect(p_module2.check).to be == [{not_passed: "2"}]
  end
end