Thumbshooter
============

Generates thumbshots of URLs by using webkit und python.


Requirements
============

Please ensure python-qt4 and qt4-webkit is installed.

    apt-get install libqt4-webkit python-qt4



Example
=======

    shooter = Thumbshooter.new(
      :screen => '800x600',
      :resize => '200x150'
    )
    
    # generate thumbnail
    img = shooter.create('http://github.com/')
    
    # write thumbnail to file
    File.open('thumbshot.png', 'w') {|f| f.write(img) }



Copyright (c) 2009 Julian Kornberger, released under the GNU license