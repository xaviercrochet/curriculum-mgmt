require 'entity'
require 'entities/course'

describe ConstraintsChecker::Entities::Course do 

  let(:parent){ double(name: "Parent")}
  it "Course check" do
    course = ConstraintsChecker::Entities::Course.new(name: "LINGI4242", credits: "4")
    course.parent = parent
    expect(course.parent.name).to include "Parent"
    expect(course.count_credits).to be == 4
    expect(course.name).to include "LINGI4242"
  end
end