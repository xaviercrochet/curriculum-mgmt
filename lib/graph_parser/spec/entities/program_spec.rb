require "entities/program"

describe GraphParser::Entities::Program do 
  let(:course){ double(name: "course") }
  let(:p_module){ double(name: "module") }
  
  it "Test Program Object" do
    program = GraphParser::Entities::Program.new(42, "program")
    program.add_course(course)
    program.add_p_module(p_module)

    expect(program.name).to include ("program")
    expect(program.courses.size).to be == 1
    expect(program.p_modules.size).to be == 1
  end
end
