require 'parser'
require 'entities/program'

describe GraphParser::Parser do 
  it "Test Graph Parser" do
    parser = GraphParser::Parser.new('spec/fixtures/data.graphml')

    expect(parser.catalog.courses.size).to be == 55
    expect(parser.catalog.programs.size).to be == 3
    expect(parser.catalog.count_p_modules).to be == 13
    expect(parser.catalog.constraint_sets.size).to be == 8
  end
end