Shoes.setup do
  gem 'geocoder'
end

require './geny_walking'
require 'pty'
require 'geocoder'
require 'expect'
require "fileutils"

Shoes.app do
  flow do
    para "GENYSHELL PATH", width: 600, margin_right: 20
    @shell_path = edit_line width: 300, height: 30
  end

  flow do
    para "START LOCATION", width: 600, margin_right: 26
    @start_location = edit_line width: 300, height: 30
  end

  flow do
    para "END LOCATION", width: 600, margin_right: 44 
    @end_location = edit_line width: 300, height: 30
  end

  flow do 
    @go_button = button "GO", margin_right: 100, margin_left: 100
    @pause_button = button "PAUSE", margin_right: 100
    @stop_button = button "STOP"
  end

  @log_box = edit_box width: 1.0, height: 400, text: 'LOG HERE...'

  geny_walking = GenyWalking.new self, @log_box
  @go_button.click do
    if @shell_path.text == ""
      alert "SET GENYSHELL PATH PLEASE"
    elsif @start_location.text == ""
      alert "SET START LOCATION PLEASE"
    elsif @end_location.text == ""
      alert "SET END LOCATION PLEASE"
    else
      geny_walking.start_walking @shell_path.text, @start_location.text, @end_location.text  
    end
  end

  @pause_button.click {geny_walking.pause_walking}
  @stop_button.click {geny_walking.stop_walking}
end
