require 'entity'
require 'entities/course'
require 'entities/p_module'

describe ConstraintsChecker::Entities::PModule do 
  it "PModule check" do
    p_module = ConstraintsChecker::Entities::PModule.new(id: "1", name: "Main")
    expect(p_module.name).to include ("Main")

    course1 = ConstraintsChecker::Entities::Course.new(name: "LINGI4242", credits: "4", id: "2")
    course2 = ConstraintsChecker::Entities::Course.new(name: "SINF4242", credits: "6", id: "3")

    p_module.add_children(course1)
    p_module.add_children(course2)

    expect(p_module.childrens.size).to be == 2
    expect(p_module.count_credits).to be == 10
    expect(p_module.find_course("2")).not_to be_nil
    expect(p_module.find_course("5")).to be_nil
  end
end