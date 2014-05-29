require 'entity'
require 'entities/course'
require 'entities/p_module'
require 'constraints/binary_constraint'
require 'student_program'

describe ConstraintsChecker::Constraints::BinaryConstraint do 
  it "Check Binary Contraint" do
    course1 = ConstraintsChecker::Entities::Course.new(name: "course1", id: '1', passed: true, start_year: "1")
    course2 = ConstraintsChecker::Entities::Course.new(name: "course2", id: '2', passed: false, start_year: "2")
    course3 = ConstraintsChecker::Entities::Course.new(name: "course3", id: '3', start_year: "3")
    course4 = ConstraintsChecker::Entities::Course.new(name: "course4", id: '4', start_year: "4", start_year: "0")
    
    c1 = ConstraintsChecker::Constraints::Prerequisite.new(1, course3, course1.id)
    c2 = ConstraintsChecker::Constraints::Prerequisite.new(2, course4, course2.id)
    c3 = ConstraintsChecker::Constraints::Corequisite.new(3, course3, course1.id)
    c4 = ConstraintsChecker::Constraints::Corequisite.new(4, course3, course2.id)

    p_module1 = ConstraintsChecker::Entities::PModule.new(name: "p_module1", id: '42')
    p_module2 = ConstraintsChecker::Entities::PModule.new(name: "p_module2", id: '43')

    course3.add_constraints([c1, c3, c4])
    course4.add_constraint(c2)

    expect(course2.passed).to be == false

    expect(course3.constraints.size).to be == 3
    expect(course4.constraints.size).to be == 1

    p_module1.add_childrens([course1, course2, course3])
    p_module2.add_childrens([course4, course2])

    expect(p_module1.childrens.size).to be == 3
    expect(p_module2.childrens.size).to be == 2

    expect(course3.check).to be == []
    expect(course4.check).not_to be_empty

    expect(p_module1.check).to be == []
    expect(p_module2.check).not_to be_empty

    catalog = ConstraintsChecker::StudentProgram.new(id: "1", name: "catalog")
    catalog.add_childrens([p_module1, p_module2])

    expect(catalog.check).not_to be_empty
  end
end