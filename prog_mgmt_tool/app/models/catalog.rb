require 'open-uri'
require 'nokogiri'
require 'spreadsheet'

class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy
	has_many :courses, dependent: :destroy
	has_many :constraints, dependent: :destroy

	def upload(data)
		if data[:data]
			uploaded_io = data[:data]
			File.open(Rails.root.join('', 'seeds', self.filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			parse
		end
	end

	def create_spreadsheet
		Spreadsheet.client_encoding = 'UTF-8'
		filename = 'spreadsheets/data-'+Time.now.to_formatted_s(:number)+'.xls'
		@book = Spreadsheet::Workbook.new
		create_course_spreadsheet
		@book.write(filename)

	end

	def create_course_spreadsheet
		sheet = @book.create_worksheet :name => 'Courses'
		courses = self.courses
		courses.each do |c|
		end
		sheet[0,0] = "TEST"
	end

	def write_properties(entity, sheet, line)
		properties = entity.properties
		i = 0
		properties.each do |p|
			i  = i + 1
		end
	end
	def parse
		@or = Hash.new
		@xor = Hash.new
		@programs = Hash.new
		@modules = Hash.new
		@sub_modules = Hash.new
		@courses = Hash.new
		@constraints = Array.new
		@nary_constraints = Hash.new
		@set_id = 0
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
		populate_database
	end

	#Order of operations is important !!!
	def populate_database
		insert_programs
		insert_modules
		insert_sub_modules
		insert_courses
		insert_constraints
	end

	def parse_node(node)

		name = ""
		is_group = false
		is_constraint = false
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

			elsif c.values[0].eql? 'graphics'
				c.children.each do |ch|
					
					if ch.values.size > 0 and ch.values[0].eql? 'customconfiguration' and (ch.content.eql? 'com.yworks.entityRelationship.attribute' or ch.content.eql? 'com.yworks.entityRelationship.relationship')
							is_constraint = true
					end
				end
			end	
		end
		if not name.eql? ""
			p "Object parsed: " + name + " - " + id  + " - " + is_group.to_s + " - " + "N-Ary Constraint ? "+ is_constraint.to_s+ " - "+ gid
			create_object(name, is_group,is_constraint, gid, id)
		end
	end

	def create_object(name, is_group, is_constraint, gid, id)
		if is_group

			if gid.eql? ""
				program = Hash.new
				program['name'] = name
				@programs[id] = program
			else
				if id.eql? '7'
					p "Found : "+name+ " - "+is_group.to_s+ " - " + gid + " - " +id
				end
				pmodule = Hash.new
				pmodule['gid'] = gid
				pmodule['name'] = name
				@modules[id] = pmodule
			end
		
		else
			if is_constraint
				nary_constraint = Hash.new
				nary_constraint['name'] = name
 				@nary_constraints[id] = nary_constraint
			else
				course = Hash.new
				course['gid'] = gid
				course['name'] = name
				@courses[id] = course
			end
		end
	end

	def parse_edge(edge)
		constraint = Hash.new
		constraint['type'] = "COREQUISITE" #default value
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
								constraint['type'] = "PREREQUISITE"
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
			program = self.programs.new
			property = program.properties.new
			property.p_type = "TYPE"
			property.value = value['name']
			property.save
			program.save
			value['id'] = program.id

		end
	end

	def insert_modules
		p "Inserting modules into database ..."
		
		@modules.each do |key, value|
			program = @programs[value['gid']]
			
			if program.nil? #Submodule
				sub_module = Hash.new
				sub_module['name'] = value['name']
				sub_module['gid'] = value['gid']
				@sub_modules[key] = sub_module
				@modules.delete(key)

			else #Module
				program = self.programs.find(program['id'])
				m = program.p_modules.new
				p = m.properties.new
				p.p_type = "NAME"
				p.value = value['name']
				p.save
				m.save
				value['id'] = m.id
			end
		end
	end
	
	def insert_sub_modules
		p "Inserting sub modules into database ..."
		
		@sub_modules.each do |key, value|
			pmodule = @modules[value['gid']]
			m = PModule.find(pmodule['id'])
			sub_module = m.sub_modules.new
			p = sub_module.properties.new
			p.p_type = "NAME"
			p.value = value['name']
			p.save
			sub_module.save
			value['id'] = sub_module.id
		end

	end
	
	def insert_courses
		p "Inserting courses into database ..."
		@courses.each do |key, value|
			pmodule = @modules[value['gid']]
			
			if pmodule.nil?
				sub_module = @sub_modules[value['gid']]
				if sub_module.nil?
					p "No such sub_module : "+ value['gid'].to_s
				end

				m = SubModule.find(sub_module['id']) unless sub_module.nil?
			
			else
				m = PModule.find(pmodule['id']) 
			end

			if ! m.nil? 
				c = m.courses.new
			else
				c = Course.new
			end
			p = c.properties.new
			p.p_type = "SIGLE"
			p.value = value['name']
			p.save
			c.catalog_id = self.id
			c.save
			value['id'] = c.id
		end
	end

	def create_constraint(course_id, set_id, role, constraint_type, set_type)
		constraint = self.constraints.new
		constraint.course_id = course_id
		constraint.set_id = set_id
		constraint.constraint_type = constraint_type
		constraint.set_type = set_type
		constraint.role = role
		constraint.save
	end

	def insert_constraints
		p "Inserting constraints into database ..."
		p "Begining with n-ary constraints ..."
		@nary_constraints.each do |key, value|
			value['set_id'] = @set_id
			p key.to_s + " - " + value.to_s
			@set_id = @set_id+ 1
		end
		@constraints.each do |value|
			p "Working on constraint : "+ value.to_s
			
			if ! @nary_constraints[value['source']].nil? 
				p "Group Constraint element source for : "+ value.to_s
				source =  @nary_constraints[value['source']]
				target = Course.find(@courses[value['target']]['id'])
				create_constraint(target.id, source['set_id'], "out", value['type'], @nary_constraints[value['source']]['name'])

			
			elsif ! @nary_constraints[value['target']].nil?
				p "Group Constraint element target for: "+ value.to_s
				target = @nary_constraints[value['target']]
				source = Course.find(@courses[value['source']]['id'])
				create_constraint(source.id, target['set_id'], "in", value['type'], @nary_constraints[value['target']]['name'])

			elsif @courses[value['source']].nil?
				p "Course not found : " + value.to_s
			
			elsif @courses[value['target']].nil?
				p "Course not found : " + value.to_s
			
			else
				value['set_id'] = @set_id
				target = Course.find(@courses[value['target']]['id'])
				source = Course.find(@courses[value['source']]['id'])
				create_constraint(source.id, @set_id, "in", value['type'], "binary")
				create_constraint(target.id, @set_id, "out", value['type'], "binary")
				@set_id = @set_id + 1
			end
		end
	end
end

