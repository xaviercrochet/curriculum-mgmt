require 'nokogiri'
require_relative 'constraint'
require_relative 'catalog'
require_relative 'entities/program'
require_relative 'entities/p_module'
require_relative 'entities/constraint_set'


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
      parse

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
      p "#CosntraintSet : " + @catalog.constraint_sets.size.to_s
    end


  private

    def get_edge_type(edge)
      edge.children.each do |c|
        if c.key?("key") and c.children.size > 0
          node = get_node_from_name(c, "PolyLineEdge")
          node = get_node_from_name(node, "Arrows")
          if node.values[1].eql? "standard"
            return "PREREQUISITE"
          elsif node.values[1].eql? "none"
            return "COREQUISITE"
          end
        end
      end
      return "NONE"
    end

    def parse_edge(edge)
      type = get_edge_type(edge)
      source_id = edge.values[1]
      target_id = edge.values[2]
      target = @catalog.find_course(target_id)
      source = @catalog.find_course(source_id)
      if target.nil? 
        set = @catalog.find_constraint_set(target_id)
        set.add_source(source)
        set.type = type
      elsif source.nil?
        set = @catalog.find_constraint_set(source_id)
        set.add_destination(target)
        set.type = type
      else
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
              if c.key?("key") and c.children.size > 0
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
          if c.key?("id") and c.values.size == 1
            parse_sub_graph(parent, c)
          elsif check_attributes(c.values, 1, "group")
            parse_entity(parent, c)
          end
        end
      end
    end

    def parse_sub_graph(parent, node)
      id = node.values[0] unless ! node.key?("id")
      node.children.each do |c|
        if c.key?("key") and c.children.size > 0
          if get_node_from_name(c, "ShapeNode")
            parse_course(parent, c, id)
          elsif get_node_from_name(c, "GenericNode")
            parse_constraint_set(c, id)
          end
        end
      end
    end

    def parse_course(parent, node, id)
      course = GraphParser::Entities::Course.new(id, get_name_for_course(node))
      course.node = node
      parent.add_course(course)
      @catalog.add_course(course)
    end

    def parse_constraint_set(node, id)
      set = GraphParser::Entities::ConstraintSet.new(id, get_name_for_constraint_set(node))
      set.node = node
      @catalog.add_constraint_set(set)
    end





    def parse_entity(parent, node)
      id = node.values[0] unless ! node.key?("id")
      p_module = nil
      node.children.each do |c|

        if c.key?("key") and c.children.size > 0
          p_module = GraphParser::Entities::PModule.new(id, get_name_for_group(c))
          p_module.node = c
          parent.add_p_module(p_module)
        else
          parse_entities(p_module, c)
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

    def get_name_for_constraint_set(node)
      node = get_node_from_name(node, "GenericNode")
      node = get_node_from_name(node, "NodeLabel")
      return node.content
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
      return false
    end

    def print_info(element)
      p "Name : "+element.name.to_s
      p "Keys : "+element.keys.to_s
      p "Values :"+element.values.to_s
    end
  end
end