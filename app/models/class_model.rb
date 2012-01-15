class ClassModel < ActiveRecord::Base

	def to_hash
		ActiveSupport::JSON.decode(self.modelstring)
	end

end
