class XgmlNode
	@id
	@name
	@gid
	@is_constraint
	@is_group
	@parent

	def initialize(attributes)

		set_id(attributes['id'])
		set_gid(attributes['gid'])
		set_name(attributes['name'])
		set_is_constraint(attributes['is_constraint'])
		set_is_group(attributes['is_group'])
		set_parent('NONE')

	end
	
	def get_id
		@id
	end

	def set_parent(node)
		@parent = node
	end


	def get_is_constraint
		@is_constraint
	end

	def get_is_group
		@is_group
	end

	def get_gid
		@gid
	end

	def get_name
		@name
	end

	def to_string
		"[id: " + get_id.to_s + ", gid: " + get_gid.to_s + ", name: " + get_name + ", constraint? " + get_is_constraint.to_s + ", group? " + get_is_group.to_s + "]"
	end 

	private

		def set_id(id)
			@id = id.to_i
		end

		def set_name(name)
			@name = name
		end

		def set_gid(gid)
			@gid = gid.to_i
		end

		def set_is_constraint(is_constraint)
			@is_constraint = is_constraint
		end

		def set_is_group(is_group)
			@is_group = is_group
		end
end