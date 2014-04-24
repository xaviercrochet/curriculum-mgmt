require 'nokogiri'
require 'entities/program'
require 'catalog'
require 'entities/p_module'

module GraphParser
  class Parser
    attr_reader :filename
    attr_reader :graph
    attr_reader :catalog

    def initialize(filename)
      @filename = filename
      @catalog = GraphParser::Catalog.new

      if File.exist?(filename)
        file = File.open(filename)
        xml_file = Nokogiri::XML(file)
        if xml_file.nil?
          p "Error while opening gxml file."
        end
        @graph = find_graph_root(xml_file)
        if @graph.nil?
          p "Graph root not found"
        end
      else
        p "File not found"
      end

    end

    def parse
      @graph.children.each do |c|
        if c.name.eql? "node"
          parse_node(c)
        elsif c.name.eql? "edge"
          parse_edge(c)
        end
      end
      p  "#Courses : " + @catalog.count_courses.to_s
      p "#Modules : " + @catalog.count_p_modules.to_s
      result =  @catalog.find_course("n0::n0::n0")
    end


private

    def parse_edge(edge)
      source_id = edge.values[1]
      target_id = edge.values[2]
      target = @catalog.find_course(target_id)
      source = @catalog.find_course(source_id)
      if target.nil? or source.nil?
      else
        type = ""
        constraint = GraphParser::Constraint.new(source, target, type)
        target.add_constraint(constraint)
      end
    end

    def parse_node(node)
      parse_program(node)
    end

    def parse_program(node)
      if node.key?("id") and node.key?("yfiles.foldertype") and check_attributes(node.values, 1, "group")
        if node.values[0].size == 2
            program = GraphParser::Entities::Program.new(node.values[0], 'NONE')
            program.node = node
            @catalog.add_program(program)
            node.children.each do |c|
              if c.key?("key") and check_attributes(c.values, 0, "d6")
                program.name = get_name_for_group(c)
              else
                parse_entities(program, c)
              end
            end

        end
      end
    end

    def parse_entities(parent, node)
      if node.key?("edgedefault") 
        node.children.each do |c|
          parse_entity(parent, c)
          parse_course(parent, c)
        end
      end
    end

    def parse_course(parent, node)
      if node.key?("id") and node.values.size == 1
        id = node.values[0] unless ! node.key?("id")
        node.children.each do |c|
          if c.key?("key") and check_attributes(c.values, 0, "d6") 
            course = GraphParser::Entities::Course.new(id, get_name_for_course(c))
            course.node = c
            parent.add_course(course)
            @catalog.add_course(course) #Plus facile pour effectuer les recherches après
          end
        end
      end
    end



    def parse_entity(parent, node)
      if check_attributes(node.values, 1, "group")
        id = node.values[0] unless ! node.key?("id")
        node.children.each do |c| 
          if c.key?("key") and check_attributes(c.values, 0, "d6")
            p_module = GraphParser::Entities::PModule.new(id, get_name_for_group(c))
            p_module.node = c
            parent.add_p_module(p_module)
          else
            parse_entities(parent, c) 
          end
        end
      end
    end

    def find_graph_root(xml_file)
      xml_file.root.children.each do |c|
        if c.key?("edgedefault") and c.key?("id") 
          if check_attributes(c.values, 1, "G")
            return c
          end
        end
      end
    end

    def check_attributes(attributes, index, value)
       attributes.size >= index and attributes[index].eql? value
    end


    def get_name_for_course(node)
      node = get_node_from_name(node, "ShapeNode")
      node = get_node_from_name(node, "NodeLabel")
      return node.content
    end

    def get_name_for_group(node)
      node = get_node_from_name(node, "ProxyAutoBoundsNode" )
      node = get_node_from_name(node, "Realizers")
      node = get_node_from_name(node, "GroupNode")
      node = get_node_from_name(node, "NodeLabel")
      return node.content
    end

    def get_node_from_name(node, name)
      node.children.each do |c|
        if c.name.eql? name
          return c
        end
      end
      return node
    end

    def print_info(element)
      p "Name : "+element.name.to_s
      p "Keys : "+element.keys.to_s
      p "Values :"+element.values.to_s
    end
  end
end