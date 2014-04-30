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

	has_attached_file :spreadsheet, path: "spreadsheets/:id/:filename"
	validates_attachment_content_type :spreadsheet, content_type: "application/vnd.ms-excel"
	has_attached_file :graph, path: "graphes/:id/:filename"
	validates_attachment :graph, content_type: {content_type: "application/xml", content_type: "application/octet-stream"}
	



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

	def parse
		graph = open(self.graph_url)
		if ! graph.nil?
			parser = GraphParser::Parser.new(graph)
			build(parser)
		end
	end

	def parse_ss
		spreadsheet = open(self.spreadsheet_url)
		if ! spreadsheet.nil?
			parser = XlsParser::XlsReader.new(spreadsheet)
			parse_spreadsheets(parser)
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
	
	def parse_spreadsheets(parser)
		parse_spreadsheet(Course, "SIGLE", parser)
		parse_spreadsheet(PModule, "NAME", parser)
		parse_spreadsheet(Program, "NAME", parser)

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

	def graph_url
		URI.escape("http://s3.amazonaws.com/curriculum_mgmt/graphes/"+self.id.to_s + "/" + self.graph_file_name)
	end

	def spreadsheet_url
		URI.escape("http://s3.amazonaws.com/curriculum_mgmt/spreadsheets/" + self.id.to_s + "/" +self.spreadsheet_file_name)
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
		program.courses << c unless program.nil?
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
			build_course(c, nil, m)
		end
	end

	def build_constraint_set(constraint_set)
		source_ids = []
		constraint_set.sources.each do |source|
			source_ids << source.real_id
		end

		destination_ids = []
		constraint_set.destinations.each do |destination|
			destination_ids << destination.real_id
		end
		sources = Course.find(source_ids)
		destinations = Course.find(destination_ids)
		Constraint.create_n_ary_constraint(sources, destinations, constraint_set.set_type, constraint_set.type)
	end

	def entities_to_hash(collection)
		entities = Array.new
		collection.each do |element|
			entities.push(element.properties_to_hash)
		end
		return entities
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
		entities = parser.parse_sheet(entity_model.page_name, entity_identificator.upcase)
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
		parser.create_spreadsheet(entities_to_hash(self.programs), "Programmes")
		parser.create_spreadsheet(entities_to_hash(self.courses), 'Cours')
		parser.create_spreadsheet(entities_to_hash(self.p_modules.without_parent), 'Modules')
		#sub_modules = SubModule.joins(p_module: :sub_modules, p_module: :program).where('programs.catalog_id' => self.id)
		#parser.create_spreadsheet(entities_to_hash(sub_modules), 'SubModules')
		# parser.create_empty_spreadsheet(PModule.constraints_header, entities_to_hash(p_modules, false), 'PModules Constraints')
		# parser.create_empty_spreadsheet(SubModule.constraints_header, entities_to_hash(sub_modules, false), 'SubModules Constraints')
		# parser.create_empty_spreadsheet(Program.constraints_header, entities_to_hash(programs, false), 'Programs Constraints')
	end
end

