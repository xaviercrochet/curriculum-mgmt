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
	belongs_to :academic_year
	has_many :users

	has_attached_file :spreadsheet, path: "spreadsheets/:id/:filename"
	validates_attachment_content_type :spreadsheet, content_type: "application/vnd.ms-excel"
	has_attached_file :graph, path: "graphes/:id/:filename"
	validates_attachment :graph, content_type: {content_type: "application/xml", content_type: "application/octet-stream"}
	
	validates :name, presence: true
	validates :graph, presence: true

	scope :main, -> {where("version = ?", 1)}
	scope :old ,-> {where("version = ?", 2)}
	scope :futur, -> {where("version = ?", 0)}
	scope :available_for_student, -> {where("version > ?", 0 )}



	def find_program(name)
		results = []
		self.programs.each do |program|
			if program.name.include? name
				results << program
			end
		end
		return results
	end

	#look for updated version of the program
	def find_updated_version
		candidates = Catalog.includes(:academic_year).available_for_student
		result = []
		candidates.each do |catalog|
			if catalog.academic_year.start_year > self.academic_year.start_year
				result << catalog
			end
		end
		return result
	end

	def main?
		self.version.eql? 1
	end

	def status
		status = "Future"
		if self.version.eql? 1
			status = "Principale"
		elsif self.version.eql? 2
			status = "Anciennne"
		end
		return status
	end

	def complete_name
		self.name + " - " + self.academic_year.name + " - version: " + self.status
	end

	# upgrade the catalog version to main
	# 0 = future version
	# 1 = main version (only one can exist)
	# 2 = old version

	def upgrade_version
		p self.version.to_s
		if ! self.version.eql? 1
			main = Catalog.main.first
			if ! main.nil?
				main.version = 2
				main.save
			end
			self.version = 1
			self.save
		end
		self.version
	end


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

	def import_graph
		graph = open(self.graph_url)
		if ! graph.nil?
			parser = GraphParser::Parser.new(graph)
			build(parser)
			export_catalog_data
		end
	end

	def export_catalog_data
		parser = XlsParser::XlsWriter.new("/tmp/data.xls")
		export_data_to_spreadsheet(parser)
		file = File.open("/tmp/data.xls")
		self.update(spreadsheet: file)
		file.close
	end

	def import_catalog_data
		spreadsheet = open(self.spreadsheet_url)
		if ! spreadsheet.nil?
			parser = XlsParser::XlsReader.new(spreadsheet)
			import_objects_data(parser)
		end
	end

	def extract_data_from_spreadsheet
		spreadsheet = open(self.spreadsheet_url)
		if ! spreadsheet.nil?
			parser = XlsParser::XlsReader.new(spreadsheet)
			import_catalog_data(parser)
		end
	end

	def has_programs?
		self.programs.count > 0
	end

	def graph_url
		URI.escape("http://s3.amazonaws.com/curriculum_mgmt/graphes/"+self.id.to_s + "/" + self.graph_file_name)
	end

	def spreadsheet_url
		URI.escape("http://s3.amazonaws.com/curriculum_mgmt/spreadsheets/" + self.id.to_s + "/" +self.spreadsheet_file_name)
	end

private

	def import_objects_data(parser)
		import_courses_data(parser)
		import_modules_data(parser)
		import_programs_data(parser)
	end

	def import_courses_data(parser)
		import_specific_object_data_from_spreadsheet(Course, "SIGLE", parser)
	end

	def import_modules_data(parser)
		import_specific_object_data_from_spreadsheet(PModule, "NAME", parser)
	end

	def import_programs_data(parser)
		import_specific_object_data_from_spreadsheet(Program, "NAME", parser)
	end




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
		p constraint.type
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
		c.properties.create(p_type: "OBLIGATOIRE", value: "NON")
		c.properties.create(p_type: "SEMESTRE", value: "NONE")
		course.real_id = c.id
		program.courses << c unless program.nil?
		p_module.courses << c unless p_module.nil?
	end

	def build_p_module(p_module, program, parent)
		m = self.p_modules.create
		m.properties.create(p_type: "NAME", value: p_module.name)
		program.p_modules << m unless ! parent.nil?
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
		p "building constraint_set sources"
		constraint_set.sources.each do |source|
			p "source found!"
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



	def import_specific_object_data_from_spreadsheet(entity_model, entity_identificator, parser)
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
			elsif ! key.nil?
				p "Course - " + entity_identificator + ": " + key + " not found!"
			end 
		end
	end



	def export_data_to_spreadsheet(parser)
		program_header = Program.header
		course_header = Course.header
		module_header = PModule.header
		parser.create_spreadsheet(program_header, entities_to_hash(self.programs), "Programmes")

		parser.create_spreadsheet(course_header, entities_to_hash(self.courses), 'Cours')
		parser.create_spreadsheet(module_header, entities_to_hash(self.p_modules.without_parent), 'Modules')
	end
end

