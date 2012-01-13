class SamplesController < ApplicationController


	def index
		@samples = Sample.find :all
	end

	# protect me!
	def delete
		sample = Sample.find params[:id]
		sample.delete
		redirect_to "samples/index"
	end

end
