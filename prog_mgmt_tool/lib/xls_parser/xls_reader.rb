require 'spreadsheet'

class XlsReader

	def initialize(filename)
		if File.exists?(filename)
			doc = File.open(filename)
		else
			p "File :" + filename.to_s + "not found!"
		end
	end
end