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
		# pixels now contains each individual pixel of img, we can pass it to a Classifier model?
		classifier = Classifier.find(params[:something])
		classifier.train(pixels,params[:classname],params[:model]) # model = the name of the model we're training

		# the following belongs in the Classifier model, unless Tom rejects abstraction...
			# create a "new term" method or screen for new terms and auto-add:
			a = NaiveBayes.new(:spam, :ham) # define terms
			a.db_filepath = 'classifiers/'params[:model]+'.nb'

			a.train(:spam, 'bad', 'word') # accepts multiple features... can we give it 3 terms for R,G,B?
			a.train(:ham, 'good', 'word')
			a.save # saves to the specified file; we should wrap in a model, store the paths... 
			# or use directory listings?

		render :text => "trained, you happy now?"
	end

	# this code will not yet run
	def classify
		# b = "this is a bad sentence".split(' ')
		b = params[:sentence].split(' ')
		a = NaiveBayes.load('classifiers/'+params[:model]+'.nb') # select a trained model
		respond_to do |format|
			format.html { render :text => a.classify(*b) } #=> [:spam, 0.03125]
			format.xml  { render :xml => a.classify(*b) }
			format.json  { render :json => a.classify(*b) }
		end
	end

end
