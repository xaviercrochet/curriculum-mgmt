module XgmlParser

	class XgmlEdge
		@type
		@source
		@destination
		
		def initialize(attributes)
			set_type(attributes['type'])
			set_source(attributes['source'])
			set_destination(attributes['destination'])
		end

		def get_type
			@type
		end


		def get_source
			@source
		end

		def get_destination
			@destination
		end

		def to_string
			"[type: " + get_type +  ", source: " + get_source.get_name + ", destination: " + get_destination.get_name + " ]"
		end

		private

		def set_type(type)
			@type = type
		end

		def set_source(course)
			@source = course
		end

		def set_destination(course)
			@destination = course
		end
	end
end