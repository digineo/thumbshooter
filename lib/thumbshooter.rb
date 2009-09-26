# 
# Binding for webkit2png
# 
class Thumbshooter
  
  WEBKIT2PNG = File.dirname(__FILE__) + '/webkit2png.py'
  
  # 
  # screen: dimension of the view part (w * h) i.e. 800x800
  # resize: resize thumbshot  (w * h) i.e. 160x160
  # format: png (any others?)
  # timeout: timeout for the page to load
  def initialize(options={})
    @args = ''
    for key,value in options
      next if value.nil?
      case key
        when :screen
          # 123x124 (width x height)
          raise ArgumentError, "invalid value for #{key}: #{value}" unless value =~ /^\d+x\d+$/
          @args << " --geometry=" + value.sub('x',' ')
        when :timeout
          @args << " --timeout=#{value}"
        when :format
          @args << " --#{key}=#{value}"
        when :resize
          raise ArgumentError, "invalid value for #{key}: #{value}" unless value =~ /^\d+x\d+$/
          @resize = value
        else
          raise ArgumentError, "unknown option: #{key}"
      end
    end
  end
  
  # creates a thumbshot
  # returns it if no output-path given
  def create(url, output=nil)
    args = @args
    args << "--output=#{output}" if output
    
    # execute webkit2png-script and save stdout
    img    = `#{WEBKIT2PNG} '#{url}' #{args}`
    status = $?.to_i
    if status != 0
      raise "webkitpng failed with status #{status}"
    end
    
    if @resize
      width,height = @resize.split("x")
      img = resize(img,width,height)
    end
    
    img
  end
  
  protected
  
  # resizes the image using RMagick
  def resize(image_data, width, height)
    img = Magick::Image.from_blob(image_data)[0]
    img.resize!(width.to_i,height.to_i)
    img.to_blob
  end
  
end