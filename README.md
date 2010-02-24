Thumbshooter
============

Generates thumbshots of URLs by using Webkit and QT4.


Requirements
============

Please ensure python-qt4 and qt4-webkit is installed.

    apt-get install libqt4-ruby libqt4-webkit

You do also need a running x server. You can use a lightweight
x server by doing "apt-get install xvfb" and enabling it:

    Thumbshooter.use_xvfb = true

Usage
=======

setup options
    shooter = Thumbshooter.new(
      :screen => '800x600',
      :resize => '600x450',
      :crop => '200x150'
    )

generate thumbnail
    img = shooter.create('http://github.com/')

write thumbnail to file
    File.open('thumbshot.png', 'w') {|f| f.write(img) }


**Options for Thumbshooter class:**

  - **screen**    
    :screen => '<width>x<height>'

    example
        :screen => '800x600'

  - **resize**    
    :resize => '<width>x<height><scaling_option>'

    scaling_option [optional]
        % - image will be resized proportionaly by percentage 
        # -  image will be resized proportionaly by width
    example
        :resize => '200x150'
        :resize => '200x150#'
        :resize => '80x50%'

  - **crop**    
    :crop => '<width>x<height><scaling_option>'

    scaling_option [optional]
        % - image will be cropped proportionaly by percentage
    example
        :crop => '200x150'
        :crop => '80x50%'

    important:
        size of croped area is based on effect of previous process: 
            :screen if :resize is not set
            :resize if :resize is set
        croped area is always gravity center of image

TO-DO
=======

Croping and resizing image should have more options, similar to "thoughtbot's Paperclip"(http://github.com/thoughtbot/paperclip) .

Copyright (c) 2009 Julian Kornberger | Digineo GmbH Germany
released under the GNU license
