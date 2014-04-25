require 'open-uri'
require 'nokogiri'
require 'spreadsheet'
require 'graph_parser/parser'
require 'xls_parser/xls_reader'
require 'xls_parser/xls_writer'

class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy
	has_many :courses, dependent: :destroy
	has_many :p_modules, dependent: :destroy
	has_many :constraint_types, dependent: :destroy
	



	def as_json(option={})
		if self.has_programs?
			{
				:name => "Catalog " + self.id.to_s,
				:children => self.programs.as_json
			}
		else
			{
				:name => "Catalog " +self.id.to_s,
 			}
 		end
	end



	def upload(data)
		if data[:data]
			uploaded_io = data[:data]
			File.open(Rails.root.join('', '', self.filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			parser = GraphParser::Parser.new(self.filename)
			build(parser)
		end
	end

	def upload_spreadsheet(data)
		if !self.ss_filename.nil?
			File.delete(self.ss_filename) if File.exists?(self.ss_filename)
		end
		self.ss_filename = "spreadsheets/"+self.faculty+"-"+self.department+"-"+Time.now.to_formatted_s(:number)+"-data.xls"
		self.save 
		if data[:data]
			uploaded_io = data[:data]
			File.open(Rails.root.join('', '', self.ss_filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			parse_spreadsheets
		end

	end
	
	def parse_spreadsheets
		parser = XlsParser::XlsReader.new(self.ss_filename)
		parse_spreadsheet(Course, "SIGLE", parser)
		parse_spreadsheet(PModule, "NAME", parser)
		parse_spreadsheet(SubModule, "Name", parser)
		parse_spreadsheet(Program, "Name", parser)

	end


	def has_programs?
		self.programs.count > 0
	end

	def create_doc
		if ! self.ss_filename.nil?
			File.delete(self.ss_filename) if File.exists?(self.ss_filename)
		end



		filename = "spreadsheets/"+self.faculty+"-"+self.department+"-"+Time.now.to_formatted_s(:number)+"-data.xls"
		self.ss_filename = filename
		self.save
		parser = XlsParser::XlsWriter.new(filename)
		create_spreadsheets(parser)

	end

	

	

	private

	def build(parser)
		parser.catalog.programs.each do |p|
			build_program(p)
		end
		parser.catalog.constraint_sets.each do |c|
			build_constraint_set(c)
		end

		parser.catalog.courses.each do |c|
			build_constraints(c.constraints)
		end
	end

	def build_constraints(constraints)
		constraints.each do |constraint|
			build_constraint(constraint)
		end
	end

	def build_constraint(constraint)
		source = Course.find(constraint.source.real_id)
		destination = Course.find(constraint.destination.real_id)
		Constraint.create_binary_constraint(source, destination, constraint.type)
	end

	def build_program(program)
		p = self.programs.create
		p.properties.create(p_type: "NAME", value: program.name)
		program.courses.each do |course|
			build_course(course, p, nil)
		end
		program.p_modules.each do |p_module|
			build_p_module(p_module, p, nil)
		end
	end

	def build_course(course, program, p_module)
		c = self.courses.create
		c.properties.create(p_type: "SIGLE", value: course.name)
		course.real_id = c.id
		program.courses << c
		p_module.courses << c unless p_module.nil?
	end

	def build_p_module(p_module, program, parent)
		m = self.p_modules.create
		m.properties.create(p_type: "NAME", value: p_module.name)
		program.p_modules << m
		parent.sub_modules << m unless parent.nil?
		p_module.p_modules.each do |pm|
			build_p_module(pm, program, m)
		end

		p_module.courses.each do |c|
			build_course(c, program, m)
		end
	end

	def build_constraint_set(constraint_set)
	end

	def entities_to_hash(collection, alldata)
		entities = Array.new
		collection.each do |element|
			if alldata
				entities.push(element.properties_to_hash)
			else
				entities.push(element.name)
			end
		end
		entities
	end

	def build_sub_modules_catalog
		@sub_module_header = Array.new
		sub_modules = Array.new
		self.sub_modules.each do |m|
			update_header(@sub_module_header, m.properties)
			sub_modules.push(m.properties_to_hash)
		end
		sub_modules
	end

	def add_constraints(entity_model, constraints, entity_identificator)

		constraints.each do |key, value|
			entity = entity_model.find_by_property(entity_identificator, key.to_s.upcase, self)
			p "Adding constraint to " + entity.name
			if ! entity.nil?
				entity.update_properties(value)
				value.each do |k, v|
					ConstraintSet.create_unary_constraint_on_properties(entity, k, v)
				end
			else
				p entity_model + " - entity_identificator "+ ": " + key + " not found!"
			end
		end
	end

	def parse_constraint_spreadsheet(entity_model, entity_identificator, parser)
		p "Parsing constraint spreadsheet for model : " + entity_model.to_s 
		constraints = parser.parse_sheet(entity_model.to_s.pluralize.upcase + " CONSTRAINTS", entity_identificator.upcase)
		
		if ! constraints.nil?
			add_constraints(entity_model, constraints, entity_identificator)
		
		else
			p "Constraint Sheet for model - " + entity_model.to_s.pluralize + " not found in spreadsheet!"
		end 	
		
	end

	def parse_spreadsheet(entity_model, entity_identificator, parser)
		entities = parser.parse_sheet(entity_model.to_s.pluralize.upcase, entity_identificator.upcase)
		if ! entities.nil?
			update_entities_properties(entity_model, entities, entity_identificator)
		else
			p "Sheet for model - " + entity_model.to_s.pluralize + " not found in spreadsheet!"
		end 
	end

	def update_entities_properties(entity_model, entities_properties, entity_identificator)
		entities_properties.each do |key, value|
			entity = entity_model.find_by_property(entity_identificator, key.to_s, self)
			value[entity_identificator] = key
			if ! entity.nil?
				entity.update_properties(value)
			else
				p "Course - " + entity_identificator + ": " + key + " not found!"
			end 
		end
	end



	def create_spreadsheets(parser)
		parser.create_spreadsheet(entities_to_hash(self.courses, true), 'Courses')
		p_modules = PModule.joins(:program).where('programs.catalog_id' => self.id)
		parser.create_spreadsheet(entities_to_hash(p_modules, true), 'PModules')
		sub_modules = SubModule.joins(p_module: :sub_modules, p_module: :program).where('programs.catalog_id' => self.id)
		parser.create_spreadsheet(entities_to_hash(sub_modules, true), 'SubModules')
		parser.create_empty_spreadsheet(PModule.constraints_header, entities_to_hash(p_modules, false), 'PModules Constraints')
		parser.create_empty_spreadsheet(SubModule.constraints_header, entities_to_hash(sub_modules, false), 'SubModules Constraints')
		parser.create_empty_spreadsheet(Program.constraints_header, entities_to_hash(programs, false), 'Programs Constraints')
	end

	def create_programs(nodes)
		programs = Hash.new
		nodes.each do |node|
			if node.get_is_group? and ! node.has_parent? and ! node.get_is_constraint?
				p = self.programs.create
				p.properties.create(:p_type => 'name', :value => node.get_name, :primary => true)
				programs[node.get_id] = {"real_id" => p.id}
			end
		end
		programs
	end

	def create_modules(programs, nodes)
		modules = Hash.new
		nodes.each do |node|
			if node.get_is_group? and ! node.get_is_constraint? and node.has_parent?
				program = programs[node.get_gid]
				if ! program.nil?
					p = self.programs.find(program['real_id'].to_i)
					m = p.p_modules.create(:catalog_id => self.id)
					m.properties.create(:p_type => 'name', :value => node.get_name, :primary => true)
					modules[node.get_id] = {"real_id" => m.id}
				end
			end
		end
		modules
	end

	def create_sub_modules(modules, nodes)
		sub_modules = Hash.new
		nodes.each do |node|
			if node.get_is_group? and ! node.get_is_constraint? and node.has_parent? and node.get_parent.has_parent?
				m = modules[node.get_gid]
				if ! m.nil?
					pm = PModule.find(m['real_id'].to_i)
					sub_module = pm.sub_modules.create(:catalog_id => self.id)
					sub_module.properties.create(:p_type => 'name', :value => node.get_name, :primary => true)
					sub_modules[node.get_id] = {"real_id" => sub_module.id}
				end
			end
		end
		sub_modules
	end

	def get_course_block(node, programs, modules, sub_modules)
		
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
			
			if ! node.get_is_group? and ! node.get_is_constraint?
				block = get_course_block(node, programs, modules, sub_modules)
				course = block.courses.new
				course.catalog_id = self.id
				course.save
				course.properties.create(:p_type => 'sigle', :value => node.get_name, :primary => true)
				courses[node.get_id] = {"real_id" => course.id}
			end
		end
		courses
	end

	def create_constraints(edges, nodes, courses)
		edges.each do |edge|
			if ! edge.get_source.get_is_constraint? and ! edge.get_destination.get_is_constraint?
				Constraint.create_binary_constraint(edge, courses, self)
			end
		end
	end

	def create_constraint_sets(edges, nodes, courses)
		nodes.each do |node|
			if node.get_is_constraint?
				Constraint.create_n_ary_constraint(node, edges, courses, self)
			end
		end
	end

	

	def create_objects(parser)
		nodes = parser.get_nodes
		edges = parser.get_edges
		print_collection(edges)
		programs = create_programs(nodes)
		modules = create_modules(programs, nodes)
		sub_modules = create_sub_modules(modules, nodes)
		courses = create_courses(programs, modules, sub_modules, nodes)
		create_constraints(edges, nodes, courses)
		create_constraint_sets(edges, nodes, courses)

	end

	def print_collection(collection)
		p "Printing collection ..."
		collection.each do |element|
			p element.to_string
		end
	end



end

