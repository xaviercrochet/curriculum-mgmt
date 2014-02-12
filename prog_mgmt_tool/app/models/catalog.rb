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
					node.children.each do |n|
						
						if n.values[0].eql? 'label' and n.values[1].eql? 'String'
							
							if /[a-zA-Z]{4,5}\d\d\d\d/.match(n.content) #MATCHES LINGI4242, SINF4242, etc
								p "Creating course ..."
								@course = Course.new
								@course.program_id = '1'
								@course.sigle = n.content
								@course.save

							else
								@pmodule = PModule.new
								@pmodule.program_id = '1'
								@pmodule.name = n.content
								@pmodule.save
							end
						end
					end
				end
			end
		end

	end
end
