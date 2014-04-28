require 'parser'
require 'entities/program'

describe GraphParser::Parser do 
  it "Test Graph Parser" do
    parser = GraphParser::Parser.new('spec/fixtures/data.graphml')
  end
end