module UsersHelper
	def first_name(name)
		name.try(:split, ' ', 2).try(:first)
	end

	def last_name(name)
		name.try(:split, ' ', 2).try(:last)
	end
end
