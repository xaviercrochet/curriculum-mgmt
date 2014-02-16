require 'open-uri'
require 'nokogiri'
class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy

	def create_courses
		f = File.open("private/seeds/"+self.filename)
		doc = Nokogiri::XML(f)
		f.close
		puts "Creating Catalog Courses ..."
		#root.elements.children = nodes
		doc.root.elements.children.each do |node|
			
			node.values.each do |v|
				
				if v.eql? 'node'
					node.children.each do |n|
						if n.values[0].eql? 'isGroup' and n.values[1].eql? 'boolean'
							p "Box detected"+n.content
						elsif n.values[0].eql? 'label' and n.values[1].eql? 'String'
							
							if /[a-zA-Z]{4,5}\d\d\d\d/.match(n.content) #MATCHES LINGI4242, SINF4242, etc
								/p "Creating course ..."
								@course = Course.new
								@course.program_id = '1'
								@course.sigle = n.content
								@course.save/
								p "Course : "+n.content


							else
								p "Program or Moudle: "+n.content
								/@pmodule = PModule.new
								@pmodule.program_id = '1'
								@pmodule.name = n.content
								@pmodule.save/
							end
						end
					end
				end
			end
		end

	end

	def parse
		@objects = Hash.new
		f = File.open("private/seeds/"+self.filename)
		doc = Nokogiri::XML(f)
		f.close
		puts "Parsing gxml file ..."
		doc.root.children.children.each do |node|
			parse_node(node)
		end
	end

	def parse_node(node)
		
		name = "NIL"
		is_group = "false"
		gid = "none"
		id = "none"
		node.children.each do |c|
			
			
			if c.values[0].eql? 'label' and c.values[1].eql? 'String'
				name = c.content

			elsif c.values[0].eql? 'id' and c.values[1].eql? 'int'
				id = c.content
				#p "Id found for: " + name + " - Id :" + id
			
			elsif c.values[0].eql? 'isGroup' and c.values[1].eql? 'boolean'
				#p "Group found: " +  name + " - " + c.content
				is_group = c.content
			
			elsif c.values[0].eql? 'gid' and c.values[1].eql? 'int'
				gid = c.content
				#p "Gid found for: " +name + " - Gid : "+gid
			end
		end
		if not name.eql? "NIL"
			p "Object parsed: " + name + " - " + id  + " - " + is_group + " - " + gid
			create_object(name, is_group, gid, id)
		end
	end

	def create_object(name, is_group, gid, id)
		p "Creating object: "+name+ " - group : ? " +is_group

		if is_group.eql? "true"

			if gid.eql? "none"
				p "Creating program ..."
				@program = Program.new
				@program.cycle = name
				@program.program_type = "NONE"
				@program.catalog_id = self.id
				@program.save
				@objects[id] = @program.id
			else
				p "Creating module ..."
				@module = PModule.new
				@module.name = name
				@module.program_id = @objects[gid]
				@module.save
				p "Object id:" +@objects[gid].to_s
				@objects[id] = @module.id
			end
		
		else
			p "Creating course ..."
			@course = Course.new
			@course.sigle = name
			@course.p_module_id = @objects[gid]
			@course.save
		end
	end
end

