class ClassifierController < ApplicationController

	# this code will not yet run
	def train
		pixels = []
		@image = Image.new
		@image.url = params[:url]
		@image.save
		# some stuff here
		img = Magick::ImageList.new(filename)
		img.each_pixel do |pixel, c, r|
			pixels.push(pixel)
		end
		# pixels now contains each individual pixel of img
		
		a = NaiveBayes.new(:spam, :ham)

		a.train(:spam, 'bad', 'word')
		a.train(:ham, 'good', 'word')

		b = "this is a bad sentence".split(' ')
		# learn to store a classification model in the database...
	end

	# this code will not yet run
	def classify
		a.classify(*b)
		  #=> [:spam, 0.03125]
	end

end
