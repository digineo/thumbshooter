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
    @screen = '1024x768'
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
          raise ArgumentError, "invalid value for #{key}: #{value}" unless value =~ /^\d+x\d+(\%|#|)$/
          @resize = value
        when :crop
          raise ArgumentError, "invalid value for #{key}: #{value}" unless value =~ /^\d+x\d+(\%|)$/
          @crop = value
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
      screen = @screen.split('x').collect{|i|i.to_i+100}.join("x") 
      # add xvfb wrapper
      command << "xvfb-run -a --server-args='-screen 0, #{screen}x24' "
    end
    
    command << "#{WEBKIT2PNG} '#{Shellwords.shellescape(url)}' #{args}"

    img    = `#{command} 2>&1`
    status = $?.to_i
    pos    = img.index("\211PNG")

    if status != 0 || !pos
      raise "#{WEBKIT2PNG} failed with status #{status}: #{img}"
    end

    # strip beginning rubish
    img = img[pos..-1]

    if @resize
      width,height = geometry(@resize)
      img = resize(img,width,height)
    end

    if @crop
      width,height = geometry(@crop)
      img = crop(img,width,height)
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
    @resize=[width, height]
    img.resize!(width,height)
    img.to_blob
  end

  # crop the image

  def crop(image_data, width, height)
    img = Magick::Image.from_blob(image_data)[0]
    img.crop!(Magick::CenterGravity, width,height)
    img.to_blob
  end

  # resolve dimension
  # #  - to scale proportionally to width
  # % - to scale in percent
  # in future:
  #     # -  to scale by dimensions
  #     > -  to scale by higher
  #     < -  to scale by lower

  def geometry(size)
      width,height,ratio = size.scan(/\d+|\%|\#$/)
      orginal_width, orginal_height = (@resize.is_a?(Array) ? @resize : @screen.split('x')).map(&:to_f)
      case ratio
        when '%'
          width, height = [orginal_width * (width.to_f/100), orginal_height * (height.to_f/100)] 
        when '#'
          aspect = orginal_width / orginal_height
          height = orginal_height / aspect
      end
      [width.to_i, height.to_i]
  end

end
