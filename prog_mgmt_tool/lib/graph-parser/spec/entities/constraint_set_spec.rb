require 'entities/constraint_set'
require 'constraint'

describe GraphParser::Entities::ConstraintSet do 
  let(:course1){ double(name: 'course1')}
  let(:course2){ double(name: 'course2')} 
  it "test constraint_set" do
    constraint = GraphParser::Constraint.new(course1, course2, "binary")
    set = GraphParser::Entities::ConstraintSet.new(42, "set")
    set.add_constraint(constraint)
    
    expect(set.type).to include("set")
    expect(set.constraints.size).to be == 1

  end
end