# 
# Binding for webkit2png
# 
class Thumbshooter
  
  # use X window virtual framebuffer?
  def self.use_xvfb=(value)
    @use_xvfb = value
  end
  
  # use X window virtual framebuffer?
  def self.use_xvfb
    @use_xvfb
  end
  
  WEBKIT2PNG = File.dirname(__FILE__) + '/webkit2png.rb'
  
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
          @screen = value
          @args << " --size=" + value
        when :timeout
          @args << " --timeout=#{value}"
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
    command = ''
    if self.class.use_xvfb
      # calculate screen size
      screen = @screen ? @screen.split('x').collect{|i|i.to_i+100}.join("x") : '1024x768'
      # add xvfb wrapper
      command << "xvfb-run -a --server-args='-screen 0, #{screen}x24' "
    end
    
    command << "#{WEBKIT2PNG} '#{url}' #{args}"
    
    img    = `#{command} 2>&1`
    status = $?.to_i
    pos    = img.index("\211PNG")
    
    if status != 0 || !pos
      raise "#{WEBKIT2PNG} failed with status #{status}: #{img}"
    end
    
    # strip beginning rubish
    img = img[pos..-1]
    
    if @resize
      width,height = @resize.split("x")
      img = resize(img,width,height)
    end
    
    img
  end
  
  # creates a thumb from direct html using a temporary file
  def create_by_html(html)
    tmp_file = Tempfile.new('thumbshot.html')
    tmp_file.write(html)
    tmp_file.close
    
    begin
      create(tmp_file.path)
    ensure
      tmp_file.close!
    end
  end
  
  protected
  
  # resizes the image using RMagick
  def resize(image_data, width, height)
    img = Magick::Image.from_blob(image_data)[0]
    img.resize!(width.to_i,height.to_i)
    img.to_blob
  end
  
end
