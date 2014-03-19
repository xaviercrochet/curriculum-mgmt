require 'open-uri'
require 'nokogiri'
require 'spreadsheet'
require 'xgml_parser/xgml_parser.rb'
require 'xls_parser/xls_writer.rb'
require 'xls_parser/xls_reader.rb'

class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy
	has_many :courses, dependent: :destroy
	has_many :p_modules, dependent: :destroy
	has_many :sub_modules, dependent: :destroy
	has_many :constraint_set_types, dependent: :destroy
	has_many :constraint_types, dependent: :destroy
	

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
		parser = XlsReader.new(self.ss_filename)
		parse_spreadsheet_for_model(Course, "SIGLE", parser)

	end



	def create_doc
		filename = "spreadsheets/"+self.faculty+"-"+self.department+"-"+Time.now.to_formatted_s(:number)+"-data.xls"
		self.ss_filename = filename
		self.save
		parser = XlsWriter.new(filename)
		create_spreadsheets(parser)

	end

	

	

	private

	def parse_spreadsheet_for_model(entity_model, entity_identificator, parser)
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
				p "Course - " + entity_identificator + ": " + key + "not found!"
			end 
		end
	end

	def create_spreadsheets(parser)
		parser.create_spreadsheet(self.courses, 'Courses')
		p_modules = PModule.joins(:program).where('programs.catalog_id' => self.id)
		parser.create_spreadsheet(p_modules, 'Modules')
		sub_modules = SubModule.joins(p_module: :sub_modules, p_module: :program).where('programs.catalog_id' => self.id)
		parser.create_spreadsheet(sub_modules, 'Sub Modules')
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
				p "MODULE : " + m.to_s
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
			
			if ! node.get_is_group? and ! node.get_is_constraint?
				p node.get_name + " - " + node.get_gid.to_s
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
				ConstraintSet.create_binary_constraint(edge, courses, self)
			end
		end
	end

	

	def create_objects(parser)
		nodes = parser.get_nodes
		edges = parser.get_edges
		print_collection(edges)
		programs = create_programs(nodes)
		p programs.size.to_s
		modules = create_modules(programs, nodes)
		sub_modules = create_sub_modules(modules, nodes)
		courses = create_courses(programs, modules, sub_modules, nodes)
		create_constraints(edges, nodes, courses)
		ConstraintSet.create_sets(edges, courses, nodes, self)

	end

	def print_collection(collection)
		p "Printing collection ..."
		collection.each do |element|
			p element.to_string
		end
	end

end

