require 'catalog'

describe GraphParser::Catalog do 
  let(:course){ double(name: "course")}
  let(:p_module){ double(name: "module")}
  it "Test Catalog" do
    catalog = GraphParser::Catalog.new

    catalog.add_course(course)
    catalog.add_p_module(p_module)

    expect(catalog.courses.size).to be == 1
    expect(catalog.p_modules.size).to be == 1
  end
end