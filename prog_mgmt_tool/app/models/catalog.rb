require 'open-uri'
require 'nokogiri'
require 'spreadsheet'
require 'xgml_parser.rb'

class Catalog < ActiveRecord::Base
	has_many :programs, dependent: :destroy
	has_many :courses, dependent: :destroy
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

	private

	def create_programs(nodes)
		programs = Hash.new
		nodes.each do |node|
			if node.get_is_group? and ! node.has_parent? and ! node.get_is_constraint?
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
			if node.get_is_group? and ! node.get_is_constraint? and node.has_parent?
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
			if node.get_is_group? and ! node.get_is_constraint? and node.has_parent? and node.get_parent.has_parent?
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
			
			if ! node.get_is_group? and ! node.get_is_constraint?
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

