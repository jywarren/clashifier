require "lib/cartesianclassifier.rb"

class ClassifierController < ApplicationController

	def index
		
	end

	# Soon we'll start accepting an image, but for now just a pixel with n color values
	def train

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
		CartesianClassifier.train(params[:classname],params[:bands],params[:author])
		render :text => "trained, you happy now?", :layout => false
	end

	def classify
		# encode RGB or NRGB color data as an n-dimensional vector, transform to string?
		bands = {:red => params[:r],:green => params[:g],:blue => params[:b]} 
		respond_to do |format|
			format.html { render :text => a.classify(*b) } #=> [:spam, 0.03125]
			format.xml  { render :xml => a.classify(*b) }
			format.json  { render :json => a.classify(*b) }
		end
	end

	def closest
		@closest = CartesianClassifier.closest(params[:bands])
		render :text => @closest.inspect, :layout => false
	end

end
