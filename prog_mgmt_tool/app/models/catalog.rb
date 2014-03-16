require 'open-uri'
require 'nokogiri'
require 'spreadsheet'
require 'xgml_parser.rb'

class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy
	has_many :courses, dependent: :destroy

	def upload(data)
		if data[:data]
			uploaded_io = data[:data]
			File.open(Rails.root.join('', '', self.filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			parser = XgmlParser.new(self.filename)
			parser.parse
			create_objects(parser)
		end
	end

	def upload_spreadsheet(data)
		if !self.ss_filename.nil?
			File.delete(self.ss_filename)
		end
		self.ss_filename = "spreadsheets/"+self.faculty+"-"+self.department+"-"+Time.now.to_formatted_s(:number)+"-data.xls"
		self.save 
		if data[:data]
			uploaded_io = data[:data]
			File.open(Rails.root.join('', '', self.ss_filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			parse_spreadsheet
		end

	end
	def parse_spreadsheet
		book = Spreadsheet.open self.ss_filename
		book.worksheets.each do |sheet|
			parse_sheet(sheet)
		end

	end


	def parse_sheet(sheet)
		header = sheet.row(0)
		
		if sheet.name.upcase.eql? "COURSES"
			col_index = find_element(header, "SIGLE")

		elsif sheet.name.upcase.eql? "MODULES"
			col_index = find_element(header, "NAME")

		elsif sheet.name.upcase.eql? "SUB MODULES"
			col_index = find_element(header, "NAME")
		end
		
		p sheet.count
		
		for i in 1..sheet.count - 1
			p sheet.row(i).to_s
			sigle = sheet.row(i)[col_index].upcase
			property = Property.where(value: sigle).first
			
			if property.nil?
				p "ENTITY NOT FOUND : "+sheet.row(i)[col_index].upcase
			
			else
				entity = property.entity
				entity.properties.each do |p|
					p.destroy
				end
				index = 0
				header.each do |p|
					if ! sheet.row(i)[index].nil?
						prop = entity.properties.new
						prop.p_type = p.to_s
						prop.value = sheet.row(i)[index].to_s
						prop.save
					end
					index = index + 1
				end
			end


		end
	end
	def find_element(row, element)
		i = 0
		row.each do |c|
			if c.eql? element
				return i
			else
				i = i +1
			end
		end
		return -1
	end


	def create_doc
		Spreadsheet.client_encoding = 'UTF-8'
		filename = "spreadsheets/"+self.faculty+"-"+self.department+"-"+Time.now.to_formatted_s(:number)+"-data.xls"
		self.ss_filename = filename
		self.save
		book = Spreadsheet::Workbook.new
		create_spreadsheets(book)

		book.write(filename)

	end

	def create_spreadsheets(book)
		create_spreadsheet(book, self.courses, 'Courses')
		p_modules = PModule.joins(:program).where('programs.catalog_id' => self.id)
		create_spreadsheet(book, p_modules, 'Modules')
		sub_modules = SubModule.joins(p_module: :sub_modules, p_module: :program).where('programs.catalog_id' => self.id)
		create_spreadsheet(book, sub_modules, 'Sub Modules')
	end

	def create_spreadsheet(book, collection, sheet_name)
		sheet = book.create_worksheet :name => sheet_name.to_s
		i = 1
		header = sheet.row(0)
		header.default_format = Spreadsheet::Format.new :weight => :bold
		collection.each do |c|
			row = sheet.row(i)
			write_properties(c, row, header)
			i = i + 1
		end
	end

	def write_properties(entity, row, header)
		properties = entity.properties
		properties.each do |p|
			row[build_header(p.p_type, header)] = p.value
		end
	end

	#Find Coresponding Column to insert propertie Value
	#If Property Type doesn't exist, insert it.
	def build_header(property_type, header)
		i = 0
		p "Handling " + property_type
		header.each do |element|
			
			if ! element.eql? property_type
				p property_type
				i = i +1

			else
				p "Matching element found in header : "+element
				p "Returning position : "+i.to_s
				return i
			end
		end
		header.push(property_type)
		return i
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
		f = File.open(self.filename)
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

	def create_object_old(name, is_group, is_constraint, gid, id)
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

	private

	def create_programs(nodes)
		programs = Hash.new
		nodes.each do |node|
			if node.get_is_group and ! node.has_parent? and ! node.get_is_constraint
				p = self.programs.create
				p.properties.create(:p_type => 'name', :value => node.get_name)
				programs[node.get_id] = {"real_id" => p.id}
			end
		end
		programs
	end

	def create_modules(programs, nodes)
		modules = Hash.new
		nodes.each do |node|
			if node.get_is_group and ! node.get_is_constraint and node.has_parent?
				program = programs[node.get_gid]
				if ! program.nil?
					p = self.programs.find(program['real_id'].to_i)
					m = p.p_modules.create
					m.properties.create(:p_type => 'name', :value => node.get_name)
					modules[node.get_id] = {"real_id" => m.id}
				end
			end
		end
		modules
	end

	def create_sub_modules(modules, nodes)
		sub_modules = Hash.new
		nodes.each do |node|
			if node.get_is_group and ! node.get_is_constraint and node.has_parent? and node.get_parent.has_parent?
				m = modules[node.get_gid]
				p "MODULE : " + m.to_s
				if ! m.nil?
					pm = PModule.find(m['real_id'].to_i)
					sub_module = pm.sub_modules.create
					sub_module.properties.create(:p_type => 'name', :value => node.get_name)
					sub_modules[node.get_id] = {"real_id" => sub_module.id}
				end
			end
		end
		sub_modules
	end

	def get_course_block(node, programs, modules, sub_modules)
		
		p "Looking block for: " + node.get_name

		if ! programs[node.get_gid].nil?
			block = self.programs.find(programs[node.get_gid]['real_id'].to_i)
		
		elsif ! modules[node.get_gid].nil?
			block = PModule.find(modules[node.get_gid]['real_id'].to_i)
		
		elsif ! sub_modules[node.get_gid].nil?
			p sub_modules[node.get_gid].to_s
			block = SubModule.find(sub_modules[node.get_gid]['real_id'].to_i)
		
		else
			block = self
		end
		block
	end

	def create_courses(programs, modules, sub_modules, nodes)
		courses = Hash.new
		nodes.each do |node|
			
			if ! node.get_is_group and ! node.get_is_constraint
				p node.get_name + " - " + node.get_gid.to_s
				block = get_course_block(node, programs, modules, sub_modules)
				course = block.courses.new
				course.catalog_id = self.id
				course.save
				course.properties.create(:p_type => 'sigle', :value => node.get_name)
				courses[node.get_id] = {"real_id" => course.id}
			end
		end
		courses
	end




	def create_group_constraints(parser)
	end
	# Creates constraint set if not exists, then returns it.
	def create_constraint_set(name)
		set = ConstraintSet.where(:name => name).first
		if set.nil?
			set = ConstraintSet.create(:name => name)
		end
		set
	end
	#Creates constraint type if not exists. Then returns it.
	def create_constraint_type(type)
		c_type = ConstraintType.where(:name => type).first
		if c_type.nil?
			c_type = ConstraintType.create(:name => type)
		end
		c_type
	end

	def create_constraint_set_type(type)
		c_set_type = ConstraintSetType.where(:name => type).first
		if c_set_type.nil?
			c_set_type = ConstraintSetType.create(:name => type)
		end
		c_set_type
	end

	def create_binary_constraint(edge, courses)
		source = Course.where(:catalog_id => self.id, :id => courses[edge.get_source.get_id]["real_id"].to_i).first
		destination = Course.where(:catalog_id => self.id, :id => courses[edge.get_destination.get_id]["real_id"].to_i).first
		set_type = create_constraint_set_type("BINARY")
		set = set_type.constraint_sets.create
		c_type = create_constraint_type(edge.get_type)
		source_constraint = source.constraints.create(:role => "IN")
		source_constraint.constraint_type = c_type
		destination_constraint = destination.constraints.create(:role => "OUT")
		destination_constraint.constraint_type = c_type

	end


	def create_constraints(edges, nodes, courses)
		edges.each do |edge|
			if ! edge.get_source.get_is_constraint and ! edge.get_destination.get_is_constraint
				p edge.get_source.to_s
				p edge.get_destination.to_s
				create_binary_constraint(edge, courses)
			elsif edge.get_source.get_is_constraint
			elsif edge.get_destination.get_is_constraint
			end
		end
	end

	

	def create_objects(parser)
		nodes = parser.get_nodes
		edges = parser.get_edges
		print_collection(edges)
		programs = create_programs(nodes)
		p "printing programs ..."
		p programs.size.to_s
		modules = create_modules(programs, nodes)
		sub_modules = create_sub_modules(modules, nodes)
		courses = create_courses(programs, modules, sub_modules, nodes)
		p "Course length : "+courses.size.to_s
		create_constraints(edges, nodes, courses)

	end

	def print_collection(collection)
		p "Printing collection ..."
		collection.each do |element|
			p element.to_string
		end
	end

end

