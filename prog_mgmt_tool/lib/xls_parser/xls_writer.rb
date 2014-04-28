require 'spreadsheet'

module XlsParser
	
	class XlsWriter
		
		attr_accessor :book
		attr_accessor :filename

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

		def create_empty_spreadsheet(header, names, sheet_name)
			sheet = @book.create_worksheet :name => sheet_name.to_s.upcase
			sheet.row(0).default_format = Spreadsheet::Format.new :weight => :bold
			i = 0
			header.each do |element|
				sheet.row(0)[i] = element.to_s
				i = i + 1
			end
			i = 1

			names.each do |n|
				sheet.row(i)[0] = n
				i = i + 1
			end
			@book.write(@filename)
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
			header.each do |element|
				
				if ! element.eql? property_type
					i = i +1

				else
					return i
				end
			end
			header.push(property_type)
			return i
		end


	end
end