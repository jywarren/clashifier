class CartesianClassifier

  # <string> classname, <hash> bands, <string> author
  # bands = {"bandname1": value1, "bandname2": value2}
  def self.train(classname,bands,author)
    # we're going to have classname collisions, better use authorname too...
    author ||= 'anonymous' # anomymous default
    bandstring = bands # must validate this as correctly-formatted JSON...
    sample = Sample.new({:classname => classname,:bandstring => bandstring,:author => author})
    sample.save

  end

  # the # of inserts necessitates some caveman tactics... 
  def self.batch_train(classname,pixels,author,image_id)
    Sample.transaction do
      pixels.each do |pixel|
        Sample.connection.execute "INSERT INTO samples (`classname`,`bandstring`,`author`,`image_id`,`xy`) values (\"#{classname}\",\"#{pixel[1]}\",\"#{author}\",#{image_id},\"#{pixel[0]}\")"
      end
    end
  end

  def self.classify

  end

  # compiles all CartesianSamples (in database) into a hash 
  # we could create another Model for this and run this only when a class is modified...?
  # I am 100% sure someone can optimize this code:
  def self.get_classes(samples) # alt name "compile_classes"
    samples_by_class = {}
    samples.each do |sample|
      # may need to create hash entry if nonexistent
      samples_by_class[sample.classname] ||= []
      samples_by_class[sample.classname] << sample
    end

    # average together by classname
    classes = {}
    samples_by_class.each do |classname,samples|
      classes[classname] = {}
      samples.each do |sample|
        bands = ActiveSupport::JSON.decode(sample.bandstring)
        bands.each do |bandname,value|
          classes[classname][bandname] ||= 0
          classes[classname][bandname] += value
        end
      end
      classes[classname].each do |band,value|
        classes[classname][band] /= samples_by_class[classname].length # divide by # of samples
      end
    end
    classes
  end

  # bands is a native ruby hash like: 
  # bands = {:bandname1 => value1, :bandname2 => value2}
  def self.closest_hash(bands,classes)
    distances = {}
    # Change to only search some classes:
    classes.each do |classname,classbands|
      distances[classname] = self.distance(classbands,bands)
    end
    distances = distances.sort_by {|classname,value| value}
    distances.first.first
  end

  # bands is a JSON string like: 
  # bands = {"bandname1": value1, "bandname2": value2}
  def self.closest(bands)
    bands = ActiveSupport::JSON.decode(bands)
    distances = {}
    self.get_classes(Sample.find :all).each do |classname,classbands|
      distances[classname] = self.distance(classbands,bands)
    end
    distances.sort_by {|classname,value| value}
  end

  # measures cartesian distance between two band hashes
  def self.distance(a,b)
    bands = 0
    a.each do |band,value|
      bands += (value.to_i-b[band].to_i)**2 unless b[band].nil?
    end
    return bands**0.5
  end

  # sorts a hash of distances like:
  # {"wetlands"=>47.0106370941726, "asphalt"=>316.393742036722}
  def self.sort_distances(distances)
    distances
  end

end
