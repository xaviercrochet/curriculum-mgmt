class XgmlEdge
	@type
	@course_source
	@course_destination
	@id
	@gid
	
	def initialize(attributes)
		set_type(attributes['type'])
		set_course_source(attributes['source'])
		set_course_destination(attributes['destination'])
	end

	def get_type
		@type
	end


	def get_course_source
		@course_source
	end

	def get_course_destination
		@course_destination
	end

	def to_string
		"[type: " + get_type +  ", source: " + get_course_source.get_name + ", destination: " + get_course_destination.get_name + " ]"
	end
	private

		def set_type(type)
			@type = type
		end

		def set_course_source(course)
			@course_source = course
		end

		def set_course_destination(course)
			@course_destination = course
		end


end