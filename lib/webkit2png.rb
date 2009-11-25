#!/usr/bin/ruby
# 
# Example call:
# 
# ./webkit2png.rb --size 800x600 --timeout 15 http://www.example.com/ > thumbshot.png
# 

require 'optparse'

# Load dependencies
begin
  require "Qt4"
  require "qtwebkit"
rescue LoadError => e
  STDERR.puts e
  STDERR.puts 'try: apt-get install libqt4-ruby libqt4-webkit'
  exit -2
end


class Thumbshooter
  
  IMAGE_TYPE = 'png'
  CHECK_LOADING_STATUS_INTERVAL = 0.1
  
  attr_accessor :timeout
  
  def initialize
    @timeout     = 30
    @state       = 'waiting'
    @progress    = 0
    @started_at  = nil
    @output      = nil
    self.screen_size = '1024x768'
  end
  
  def screen_size=(value)
    raise ArgumentError, "invalid size: #{value}" unless value =~ /^(\d+)x(\d+$)/
    @screen_size = Qt::Size.new($~[0].to_i, $~[1].to_i)
  end
  
  def generate(url)
    app     = Qt::Application.new(ARGV)
    webview = Qt::WebView.new()
    
    webview.connect(SIGNAL("loadStarted()")) do
      @started_at = Time.now.to_i
    end
    
    webview.connect(SIGNAL('loadFinished(bool)')) do |result|
      if result
        @state = 'finished-success'
      else
        @state = 'finished-fail'
        @progress = false
      end
      suspend_thread # Give it enough time to switch to the sentinel thread and avoid an empty exec loop
    end
    
    webview.connect(SIGNAL("loadProgress(int)")) do |progress|
      @progress = progress
      suspend_thread if has_reached_time_out?
    end
    
    # Hide the scrollbars
    mainFrame = webview.page.mainFrame
    mainFrame.setScrollBarPolicy(Qt::Horizontal, Qt::ScrollBarAlwaysOff)
    mainFrame.setScrollBarPolicy(Qt::Vertical,   Qt::ScrollBarAlwaysOff)
    
    webview.load(Qt::Url.new(url))
    webview.resize(@screen_size)
    webview.show
    render_page_thread = Thread.new do
      app.exec
    end
    
    check_status_thread = Thread.new do
      while true do
        sleep CHECK_LOADING_STATUS_INTERVAL
        if @state =~ /^finished/ || has_reached_time_out?
          # Save a screenshot if page finished loaded or it has timed out with 50%+ completion
          if @state == 'finished-success' || (@progress && @progress >= 50)
            save_screenshot(webview)
          end
          render_page_thread.kill
          break
        end
      end
    end
    
    check_status_thread.join
    render_page_thread.join
    
    # percentage of completion
    @progress
  end
  
  def output
    @output
  end
  
  def progress
    @progress
  end
  
  private
  
  def has_reached_time_out?
    Time.now.to_i >= (@started_at + timeout)
  end
  
  def suspend_thread
    sleep(20)
  end
  
  def save_screenshot(webview)
    pixmap = Qt::Pixmap.grabWindow(webview.window.winId)
    
    # save directly to file
    # pixmap.save('thumbshot.png', 'png')
    
    byteArray = Qt::ByteArray.new
    buffer    = Qt::Buffer.new(byteArray)
    buffer.open(Qt::IODevice::WriteOnly)
    
    pixmap.save(buffer, IMAGE_TYPE)
    @output = byteArray
  end
  
end


shooter = Thumbshooter.new

# Parse arguments
opts = OptionParser.new 
opts.on('--size WIDTHxHEIGHT') do |arg|
  shooter.screen_size = arg
end

opts.on('--timeout SECONDS', Integer) do |arg|
  shooter.timeout = arg
end
opts.parse!

# generate thumbshot
shooter.generate(ARGV.last)

# return result
if shooter.output
  puts shooter.output
else
  STDERR.puts "failed at progress: #{shooter.progress}"
  exit -1
end
