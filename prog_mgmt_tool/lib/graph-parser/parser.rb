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
      @catalog.print
    end


private

    def parse_edge(edge)
    end

    def parse_node(node)
      parse_program(node)
    end

    def parse_program(node)
      if node.key?("id") and node.key?("yfiles.foldertype") and check_attributes(node.values, 1, "group")
        if node.values[0].size == 2
            p "*******************************************************************"
            program = GraphParser::Entities::Program.new(node.values[0], 'NONE')
            program.node = node
            @catalog.add_program(node.values[0], program)
            node.children.each do |c|
              if c.key?("key") and check_attributes(c.values, 0, "d6")
                program.name = get_name_for_group(c)
                p program.name
              else
                parse_entities(program, c)
              end
            end

        end
      end
    end

    def parse_entities(parent, node)
      if node.key?("id")
        if node.key?("edgedefault") 
          node.children.each do |c|
            parse_entity(parent, c)
          end
        else
          p "course found!!"
        end
      end
    end

    def parse_entity(parent, node)
      if check_attributes(node.values, 1, "group")
        p "---------------------------------------------------------------------"
        id = node.values[0] unless ! node.key?("id")
        print_info(node)
        node.children.each do |c| 
          if c.key?("key") and check_attributes(c.values, 0, "d6")
            p get_name_for_group(c)
            p_module = GraphParser::Entities::PModule.new(id, get_name_for_group(c))
            p_module.node = c
            parent.add_p_module(id, p_module)
            p " * * *"
            print_info(c)
            p " * * *"
          else
            parse_entities(p_module, node) 
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