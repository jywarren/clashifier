#require "lib/cartesianclassifier.rb"

class ClassifierController < ApplicationController

	def index
		@classmodels = ClassModel.find :all
	end

	def image
		render :layout => false
	end

	def proxy
		if params[:url][-3..-1].downcase == "png" || params[:url][-3..-1].downcase == "jpg"
		    url = URI.parse(params[:url])
		    req = Net::HTTP::Get.new(url.path)
		    res = Net::HTTP.start(url.host, url.port) {|http|
		      http.request(req)
		    }
		    if res.inspect == "#<Net::HTTPMovedPermanently 301 Moved Permanently readbody=true>"
		      render :text => 'failure'
		    else
		      headers['Content-Type'] = 'image/jpeg'
		      headers['Cache-Control'] = 'public' 
		      headers['Expires'] = 'Mon, 28 Jul 2020 23:30:00 GMT' 
		      render :text => res.body
		    end
		end
	end

	def classify
		@closest = CartesianClassifier.closest(params[:bands])
		respond_to do |format|
			format.html { render :text => @closest.inspect } #=> [:spam, 0.03125]
			format.xml  { render :xml => @closest }
			format.json  { render :json => @closest }
		end
	end

	# given a comma-delimited list of classnames, generate a compiled model of the classes from available samples
        def generate_model
		classes = CartesianClassifier.get_classes(Sample.find_all_by_classname(params[:classnames].split(',')))
		classmodel = ClassModel.new({
			:classnames => params[:classnames], # split and join again for validation?
			:modelstring => ActiveSupport::JSON.encode(classes),
			:author => params[:author],
			:notes => params[:notes]
		})
		classmodel.save
		redirect_to "/"
        end

	# will have to recommend only using for a set of images from the same day, camera... 
	# /classifier/classify_image?url=http://farm4.staticflickr.com/3319/4587904129_0bebca032e_m.jpg&classnames=river,highway
	def classify_image

		require 'rubygems'
		require 'RMagick'
		require "open-uri"

		imagelist = Magick::ImageList.new # not sure why using ImageList and not an Image, but thats the example. can try rewrite 
		urlimage = open(params[:url]) # Image URL 
		imagelist.from_blob(urlimage.read)
		image = imagelist.cur_image

	puts "image opened, color coding"

		colorcodes = {
			:red => [255,0,0],
			:green => [0,255,0],
			:blue => [0,0,255],
			:yellow => [255,255,0],
		}
		@colors = {}
		@classmodel = ClassModel.find params[:classmodel]
		classnames = @classmodel.classnames.split(',') # user-supplied classes; 
		classnames.each_with_index do |classname,index|
			@colors[classname] = colorcodes.to_a[index]
		end

	puts "assembling classes"

		classes = ClassModel.find(params[:classmodel]).to_hash

	puts "parsing pixels and writing new pixels"

		# this can also surely be more efficient, look at: http://www.simplesystems.org/RMagick/doc/image2.html#import_pixels
		(0..image.columns-1).each do |x|
			(0..image.rows-1).each do |y|
				# classify the pixel
				# first, extract a JSON string of the colors... inefficient but a start:
				a = image.export_pixels(x, y, 1, 1, "RGB");
				pixel_string = {"red" => a[0]/255,"green" => a[1]/255,"blue" => a[2]/255} # MaxRGB is 255^2
					#puts pixel_string
				closest = CartesianClassifier.closest_hash(pixel_string,classes)
					#puts closest
				# match the resulting class to a color and write to a pixel
				a = colorcodes[@colors[closest][0]].map { |c| c*255 } #MaxRGB is 255^2
				image.import_pixels(x, y, 1, 1, "RGB", a);
			end
		end
		respond_to do |format|
			format.html { 
				@b64 = Base64.encode64(image.to_blob)
			}
			format.png { 
				headers['Content-Type'] = 'image/png'
				headers['Cache-Control'] = 'public'
				headers['Expires'] = 'Mon, 28 Jul 2020 23:30:00 GMT'
				render :text => image.to_blob
			}
		end
	end

	def train
		pixels = ActiveSupport::JSON.decode(params[:pixels])
			# begin storing image URL and pixel x,y with each sample...
			CartesianClassifier.batch_train(params[:classname],pixels,params[:author],params[:image_id])
		render :text => "trained, you happy now?", :layout => false
	end

	# for now, let's stick with a model-less system where you pass a :model parameter with every request
	def train_pixel
		if CartesianClassifier.train(params[:classname],params[:bands],params[:author])
			render :text => "trained as '"+params[:classname]+"', you happy now?", :layout => false
		else
			render :text => "failed to train", :layout => false
		end
	end

end
