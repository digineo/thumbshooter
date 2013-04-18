# load ImageMagick
unless defined?(Magick)
  # load RubyGems
  require 'rubygems'

  # load RMagick
  gem "rmagick"
  require 'RMagick'
end

require "tempfile"
require "shellwords"

# load classes
require File.dirname(__FILE__) + '/lib/thumbshooter'
