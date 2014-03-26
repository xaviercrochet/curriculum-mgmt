require 'spreadsheet'

class XlsWriter
	
	@book
	@filename

	def initialize(filename)
		Spreadsheet.client_encoding = 'UTF-8'
		@book = Spreadsheet::Workbook.new
		@filename = filename
		
	end

	def create_spreadsheet(collection, sheet_name)
		sheet = @book.create_worksheet :name => sheet_name.to_s.upcase
		i = 1
		header = sheet.row(0)
		header.default_format = Spreadsheet::Format.new :weight => :bold
		collection.each do |c|
			row = sheet.row(i)
			write_properties(c, row, header)
			i = i + 1
		end
		@book.write(@filename)
	end


	def get_book
		@book
	end

	private

	def write_properties(properties, row, header)
		properties.each do |key, value|
			row[build_header(key, header)] = value
		end
	end

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


end