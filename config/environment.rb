# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Clashifier::Application.initialize!

Mime::Type.register 'image/png', :png
