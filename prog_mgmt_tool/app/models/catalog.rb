require 'open-uri'
require 'nokogiri'
class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy

	def create_courses
		f = File.open("seeds/"+self.filename)
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
		@programs = Hash.new
		@modules = Hash.new
		@courses = Hash.new
		@constraints = Array.new
		f = File.open("seeds/"+self.filename)
		doc = Nokogiri::XML(f)
		f.close
		puts "Parsing gxml file ..."
		doc.root.children.children.each do |c|
			if c.values[0].eql? 'node'
				parse_node(c)
			elsif c.values[0].eql? 'edge'
				parse_edge(c)
			end
				
		end
		insert_programs
		insert_modules
		insert_courses
		insert_constraints
	end

	def parse_node(node)

		name = ""
		is_group = false
		gid = ""
		id = ""
		node.children.each do |c|
			
			
			if c.values[0].eql? 'label' and c.values[1].eql? 'String'
				name = c.content

			elsif c.values[0].eql? 'id' and c.values[1].eql? 'int'
				id = c.content
				#p "Id found for: " + name + " - Id :" + id
			
			elsif c.values[0].eql? 'isGroup' and c.values[1].eql? 'boolean' and c.content.eql? "true"
				#p "Group found: " +  name + " - " + c.content
				is_group = true
			
			elsif c.values[0].eql? 'gid' and c.values[1].eql? 'int'
				gid = c.content
				#p "Gid found for: " +name + " - Gid : "+gid
			end
		end
		if not name.eql? ""
			p "Object parsed: " + name + " - " + id  + " - " + is_group.to_s + " - " + gid
			create_object(name, is_group, gid, id)
		end
	end

	def create_object(name, is_group, gid, id)
		p "Creating object: "+name+ " - group ? " +is_group.to_s

		if is_group

			if gid.eql? ""
				p "Creating program ..."
				program = Hash.new
				program['name'] = name
				@programs[id] = program
				/@program = Program.new
				@program.cycle = name
				@program.program_type = "NONE"
				@program.catalog_id = self.id
				@program.save
				@objects[id] = @program.id
				@objects_type[id] = "program"/
			else
				p "Creating module ..."
				pmodule = Hash.new
				pmodule['gid'] = gid
				pmodule['name'] = name
				@modules[id] = pmodule
				/@module = PModule.new
				@module.name = name
				@module.program_id = @objects[gid]
				@module.save
				@objects[id] = @module.id
				@objects_type[id] = "module"/
			end
		
		else
			p "Creating course ..."
			course = Hash.new
			course['gid'] = gid
			course['name'] = name
			@courses[id] = course
			/@course = Course.new
			@course.sigle = name
			@course.p_module_id = @objects[gid]
			@course.save
			@objects[id] = @course.id
			@objects_type[id] = "course"/
		end
	end

	def parse_edge(edge)
		constraint = Hash.new
		p "Parsing Edge ... "
		edge.children.each do |c|
			if c.values.size > 0

				
				if c.values[0].eql? 'source' and c.values[1].eql? 'int'
					constraint['source'] = c.content

				elsif c.values[0].eql? 'target' and c.values[1].eql? 'int'
					constraint['target'] = c.content
				
				elsif c.values[0].eql? 'graphics'
					c.children.each do |ch|
						if ch.values.size > 0
							if ch.values[0].eql? 'targetArrow' and ch.values[1].eql? 'String'
								p "Prerequisite found."
								constraint['type'] = "PREREQUISITE"
							else
								constraint['type'] = "COREQUISITE"
							end
						end
					end

				end

				
			end
		end
		@constraints.push(constraint)
		
	end

	def parse_edge_vertices
		@source_id = @objects[@source.content]
		@target_id = @objects[@target.content]
		@source_type = @objects_type[@source.content]
		@target_type = @objects_type[@target.content]
		
		if @source_type.eql? "course" and @target_type.eql? "course"
			@course_source = Course.find(@source_id)
			@course_target = Course.find(@target_id)
			p "Constraint between " + @course_source.sigle + " and " + @course_target.sigle
			create_course_constraint(@course_source, @course_target, @constraint)



		end
	end

	def create_course_constraint(source, target, constraint_type)

		#none is the default arrow in yED.
		if constraint_type.eql? "NONE"
			constraint_type = "COREQUISITE"
		end
		@cc = CourseConstraint.new
		@cc.course_id = target.id
		@cc.second_course_id = source.id
		@cc.constraint_type = constraint_type
		@cc.save
	end

	def insert_programs
		p "Inserting programs into database ..."
		@programs.each do |key, value|
			program = Program.new
			program.catalog_id = self.id
			program.cycle = "NONE"
			program.program_type = value['name']
			program.save
			value['id'] = program.id

		end
	end

	def insert_modules
		p "Inserting modules into database ..."
		@modules.each do |key, value|
			m = PModule.new
			m.program_id = @programs[value['gid']]['id'] unless program.nil? #Have to implement support for nested modules!!
			m.name = value['name']
			m.module_type = "NONE"
			m.save
			value['id'] = m.id
		end
	end

	def insert_courses
		p "Inserting courses into database ..."
	end

	def insert_constraints
		p "Inserting constraints into database ..."
	end
end

