require 'parser'
require 'entities/program'

describe GraphParser::Parser do 
  it "Test Graph Parser" do
    parser = GraphParser::Parser.new('spec/fixtures/data.graphml')

    expect(parser.catalog.courses.size).to be == 29
    expect(parser.catalog.programs.size).to be == 2
    expect(parser.catalog.count_p_modules).to be == 6
    expect(parser.catalog.constraint_sets.size).to be == 2
  end
end