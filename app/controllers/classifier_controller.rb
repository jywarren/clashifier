class ClassifierController < ApplicationController

	def create
		#a = NaiveBayes.new(:spam, :ham) # define terms
		a = NaiveBayes.new(params[:classes]) # if auto-adding a class, just define one for now 
		a.db_filepath = 'classifiers/'params[:model]+'.nb'
		a.save
	end

	def train
		# Soon we'll start accepting an image, but for now just a pixel with n color values

			#pixels = []
			#@image = Image.new
			#@image.url = params[:url]
			#@image.save

			# some stuff here

			#img = Magick::ImageList.new(filename)
			#img.each_pixel do |pixel, c, r|
			#	pixels.push(pixel)
			#end
			# pixels now contains each individual pixel of img, we can pass it to a Classifier model?

			#classifier = Classifier.find(params[:something])
			#classifier.train(pixels,params[:classname],params[:model]) # model = the name of the model we're training

	end

	# for now, let's stick with a model-less system where you pass a :model parameter with every request
	def train_pixel
		self.train(params[:classname],params[:bands],params[:author])
		render :text => "trained, you happy now?"
	end

	def classify
		# b = "this is a bad sentence".split(' ')

		# encode RGB or NRGB color data as an n-dimensional vector, transform to string?
		b = [params[:r],params[:g],params[:b]] # how to search on combined color value, 
							# or specify feature type from r,g,b?
		a = NaiveBayes.load('classifiers/'+params[:model]+'.nb') # select a trained model
		respond_to do |format|
			format.html { render :text => a.classify(*b) } #=> [:spam, 0.03125]
			format.xml  { render :xml => a.classify(*b) }
			format.json  { render :json => a.classify(*b) }
		end
	end

end
