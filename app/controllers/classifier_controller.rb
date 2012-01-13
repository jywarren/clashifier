require "lib/cartesianclassifier.rb"

class ClassifierController < ApplicationController

	def index
		
	end

	# Soon we'll start accepting an image, but for now just a pixel with n color values
	def train

		#pixels = []

		# do we really need to save the image? can't we examine it in tmp?
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
		CartesianClassifier.train(params[:classname],params[:bands],params[:author])
		render :text => "trained, you happy now?", :layout => false
	end

	def classify
		@closest = CartesianClassifier.closest(params[:bands])
		respond_to do |format|
			format.html { render :text => @closest.inspect } #=> [:spam, 0.03125]
			format.xml  { render :xml => @closest }
			format.json  { render :json => @closest }
		end
	end

end
