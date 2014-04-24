require "entities/program"

describe GraphParser::Entities::Program do 
  let(:course){ double(name: "course") }
  let(:p_module){ double(name: "module") }
  
  it "Test Program Object" do
    program = GraphParser::Entities::Program.new("program")
    program.add_course(1, course)
    program.add_p_module(1, p_module)

    expect(program.name).to include ("program")
    expect(program.courses.size).to be == 1
    expect(program.p_modules.size).to be == 1
  end
end
