class Sample < ActiveRecord::Base

	validates_presence_of :classname, :bandstring

	# ensure it's JSON and correctly formatted
	def validate
		
	end

end
