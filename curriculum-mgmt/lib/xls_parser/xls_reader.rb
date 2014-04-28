require 'spreadsheet'
module XlsParser
	class XlsReader
		attr_accessor :book
		attr_accessor :filename

		def initialize(filename)
			@filename = filename
			@book = Spreadsheet.open @filename 
		end

		def self.header(sheet)
			sheet.row(0)
		end

		def self.meta_header(sheet)
			sheet.row(1)
		end

		

		def parse_sheet(name, resource_indentifier)
			sheet = find_sheet(name)
			if ! sheet.nil?
				extract_data_from_sheet(sheet, resource_indentifier)
			else
				p "Sheet " + name.to_s + " not found!"
				nil
			end
		end

	private

		def find_resource_identifier(sheet, name)
			i = 0
			header = XlsReader.header(sheet)
			header.each do |p|
				if p.to_s.upcase.eql? name
					return i
				else
					i = i + 1
				end
			end
			-1
		end

		#extract all the data from one row while not inserting row[id] (as it's used further as identifier)!
		def extract_data_from_row(row, id, header)
			i = 0
			line = Hash.new
			row.each do |element|
				if i != id
					line[header[i]] = element.to_s
				end
				i = i + 1
			end
			line

		end

		def extract_data_from_sheet(sheet, resource_identifier)
			header = XlsReader.header(sheet)
			data = Hash.new
			id = find_resource_identifier(sheet, resource_identifier)
			if id == -1
				p "Resource identifier - " + resource_identifier.to_s + " - not found, using column 0 as identifier."
				id = 0
			end

			for i in 1..sheet.count - 1
				row = sheet.row(i)
				name = row[id]
				line = extract_data_from_row(row, id, header)
				data[name] = line
			end
			data
		end

		def find_sheet(name)
			@book.worksheets.each do |sheet|
				if sheet.name.upcase.eql? name.to_s
					p "Sheet found!"
					return sheet
				end
			end
			p "Sheet not found!"
			return nil
		end

	end
end