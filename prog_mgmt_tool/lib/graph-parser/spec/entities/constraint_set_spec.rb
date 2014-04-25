require 'entities/constraint_set'
describe GraphParser::Entities::ConstraintSet do 
  let(:course1){ double(name: 'course1')}
  let(:course2){ double(name: 'course2')} 
  it "test constraint_set" do
    set = GraphParser::Entities::ConstraintSet.new(42, "set")
    set.add_destination(course1)
    set.add_source(course2)
    
    expect(set.set_type).to include("set")
    expect(set.sources.size).to be == 1
    expect(set.destinations.size).to be == 1

  end
end