require 'constraints/property_constraint'
require 'entity'
require 'entities/course'
require 'entities/p_module'

describe ConstraintsChecker::Constraints::PropertyConstraint do 
  it "Binary Constraint Check" do
    course1 = ConstraintsChecker::Entities::Course.new(name: "SINF4242", id: "1", credits: "5" )
    course2 = ConstraintsChecker::Entities::Course.new(name: "LINGI4242", id: "2", credits: "4" )
    course3 = ConstraintsChecker::Entities::Course.new(name: "SINF10000", id: "3")
    p_module = ConstraintsChecker::Entities::PModule.new(name: "Test", id: "42")
    p_module.add_childrens([course1, course2, course3])
    c1 = ConstraintsChecker::Constraints::Min.new(p_module, "5")
    c2 = ConstraintsChecker::Constraints::Min.new(p_module, "42")
    c3 = ConstraintsChecker::Constraints::Max.new(p_module, "5")
    c4 = ConstraintsChecker::Constraints::Max.new(p_module, "42")
    expect(c1.check).to be == true
    expect(c4.check).to be == true
    expect(c2.check).to be == false
    expect(c3.check).to be == false
    p_module.add_constraints([c1, c2, c3, c4])
    expect(p_module.check.size).to be == 2
  end
end