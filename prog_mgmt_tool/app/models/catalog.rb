require 'open-uri'
require 'nokogiri'
class Catalog < ActiveRecord::Base

	def create_courses
		f = File.open("private/seeds/"+self.filename)
		doc = Nokogiri::XML(f)
		f.close
		puts "Creating Catalog Courses ..."
		#root.elements.children = nodes
		doc.root.elements.children.each do |node|
			
			node.values.each do |v|
				
				if v.eql? 'node'
					p v
					node.children.each do |n|
						
						if n.values[0].eql? 'label' and n.values[1].eql? 'String'
							
							if n.content.eql? 'SEPS CORE' or n.content.eql'MINEURE+Q3' or n.content.eql? 'OR' or n.content.eql? 'X' or n.content.eql? 'CESS' or n.content.eql? 'APPROFONDISSEMENT' or n.content.eql? 'BACHELIER' or n.content.eql? 'INTRO'
								@pmodule = PModule.new
								@pmodule.program_id = '1'
								@pmodule.name = n.content
								@pmodule.save
							else
								p "Creating course ..."
								@course = Course.new
								@course.program_id = '1'
								@course.sigle = n.content
								@course.save
							end
						end
					end
				end
			end
			#puts "values:"
			#puts node.values
			#puts "name: "+node.name
			#puts "keys:"
			#puts node.keys
			#if node.keys.eql? 'label'
			#	puts "COUCOU"
			#end
		end

	end
end
