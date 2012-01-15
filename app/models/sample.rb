class Sample < ActiveRecord::Base

	validates_presence_of :classname, :bandstring

	# ensure it's JSON and correctly formatted
	# overwriting validate is deprecated!! omg i'm out of date!
	#def validate
		
	#end

end
