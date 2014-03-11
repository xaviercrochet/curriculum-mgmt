require 'nokogiri'
require 'open-uri'
require 'xgml_node'
require 'xgml_edge'
class XgmlParser

		@gxml_file
		@nodes
		@edges

		DEFAULT_ID = -1
		DEFAULT_GID = -1
		DEFAULT_NAME = "NONE"
		DEFAULT_IS_GROUP = false
		DEFAULT_IS_CONSTRAINT = false

	def initialize(filename)
		if File.exist?(filename)
			p "File : "+filename.to_s+ " found!"
			graph = File.open(filename)
			@nodes = Array.new
			@edges = Array.new
			get_nodes
			read_xgml_file(graph)
			graph.close
		else
			p "File : "+filename.to_s+ " not found!"
		end
	end

	#Return nodes of the graph. Depth is two.
	def get_nodes
		@nodes
	end

	def get_edges
		@nodes
	end

	def read_xgml_file(file)
		@gxml_file = Nokogiri::XML(file)
		if @gxml_file.nil?
			p "Error while opening gxml file."
		end
	end

	def parse
		parse_graph
	end

	private
		def add_node(node)
			@nodes[node.get_id.to_i] = node 
		end

		def check_attribute(attribute, index, field)
			if attribute.values.size > 0
				attribute.values[index].eql? field
			else
				return false
			end
		end

		def check_attributes(attribute, field_1, field_2)
			check_attribute(attribute, 0, field_1) and check_attribute(attribute, 1, field_2)
		end

		def attribute_content(attribute)
			attribute.content
		end
			
		def is_name?(attribute)
			check_attributes(attribute, 'label', 'String')
		end

		def is_id?(attribute)
			check_attributes(attribute, 'id', 'int')
		end

		def is_group?(attribute)
			check_attributes(attribute, 'isGroup', 'boolean') and attribute_content(attribute)
		end

		def is_gid?(attribute)
			check_attributes(attribute, 'gid', 'int')
		end

		def is_graphics?(attribute)
			check_attribute(attribute, 0, 'graphics')
		end

		def is_shape?(attribute)
			check_attributes(attribute, 'curstomconfiguration', 'com.yworks.entityRelationship.attribute') or check_attributes(attribute, 'curstomconfiguration', 'com.yworks.entityRelationship.relationship')
		end

		def is_constraints_set?(attribute)
			if is_graphics?(attribute)
				attribute.children.each do |ch|
					if is_shape?(ch)
						return true
					end
				end
			end
			return false
		end

		def parse_node_attributes(graph_node)
			attributes = Hash.new
			attributes['name']  = DEFAULT_NAME
			attributes['gid'] = DEFAULT_GID
			attributes['id'] = DEFAULT_ID
			attributes['is_group'] = DEFAULT_IS_GROUP
			attributes['is_constraint'] = DEFAULT_IS_CONSTRAINT
			graph_node.children.each do |a|
				if is_id?(a)

					attributes['id'] = attribute_content(a)
				
				elsif is_name?(a)
					attributes['name'] = attribute_content(a)

				elsif is_group?(a)
					attributes['is_group'] = true

				elsif is_gid?(a)
					attributes['gid'] = attribute_content(a)

				elsif is_constraints_set?(a)
					attributes['is_constraint'] = true
				end
			end
			attributes
		end

		def parse_node(graph_node)
			attributes = Hash.new

			attributes = parse_node_attributes(graph_node)
			if attributes['is_group']
			else
				node = XgmlNode.new(attributes)
				add_node(node)
			end
		end

		def parse_edge(edge)
		end

		def parse_graph
			@gxml_file.root.children.children.each do |c|
				if c.values[0].eql? 'node'
					parse_node(c)
				elsif c.values[0].eql? 'edge'
					parse_edge(c)
				end
		end
	end
end