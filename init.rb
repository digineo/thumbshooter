# load ImageMagick
unless defined?(Magick)
  # load RubyGems
  require 'rubygems'

  # load RMagick
  gem "rmagick"
  require 'RMagick'
end

require "tempfile"

# load classes
require File.dirname(__FILE__) + '/lib/thumbshooter'
