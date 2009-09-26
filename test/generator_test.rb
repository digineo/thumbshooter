require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    shooter = Thumbshooter.new(
      :screen => '800x600',
      :resize => '200x150'
    )
    
    # exmaple file
    html_file = File.dirname(__FILE__) + '/test.html'
    
    # generate thumbnail
    img = shooter.create(html_file)
    
    # is it an png?
    assert_equal "\211PNG", img[0..3]
  end
end