class GenyWalking
  MAX_SPEED = 10

  def initialize app, log_box
    @app = app
    @log_box = log_box
    @pid = nil
    @pause = false
  end

  def stop_walking
    @pid = nil
    add_log "stop..."
  end

  def pause_walking
    @pause = true
    add_log "PAUSE WALKING"
  end

  def start_walking shell_path, start_location, end_location
    if @pause 
      @pause = false
    elsif @pid
      add_log "SCRIPT IS RUNNING"
    else
      create_walking shell_path, start_location, end_location
    end
  end
    
  def create_walking shell_path, start_location, end_location
    start_pos = start_location.split(",")
    end_pos = end_location.split(",")
    
    total_kms = Geocoder::Calculations.distance_between start_pos, end_pos, :units => :km
    add_log "Distance: #{total_kms} km" 

    steps = (total_kms * 1000 / MAX_SPEED).to_i
    lat_step = (end_pos[0].to_f - start_pos[0].to_f) / steps
    long_step = (end_pos[1].to_f - start_pos[1].to_f) / steps

    new_lat = start_pos[0].to_f
    new_long = start_pos[1].to_f
    cur_step = 0

    Thread.new do
      begin
        pty = PTY.spawn(shell_path) do |stdout, stdin, pid|
          add_log "initialize..."
          stdout.expect('Genymotion Shell >')

          @pid = pid
          while cur_step < steps
            if @pid.nil?
              stdin.puts "quit"
              stdout.expect('Genymotion Shell >')
            end

            if !@pause
              cur_step += 1
              new_lat += lat_step
              new_long += long_step

              add_log "New positon: #{new_lat.round(6)}, #{new_long.round(6)}"

              stdin.puts "gps setlongitude #{new_long}"
              stdout.expect('Genymotion Shell >')
              stdin.puts "gps setlatitude #{new_lat}"
              stdout.expect('Genymotion Shell >')
            end

            sleep 5
          end    
        end

      rescue Errno::EIO
        add_log "STOPPED WALKING"
      rescue Errno::ENOENT
        add_log "WRONG GENYSHELL PATH"
      rescue PTY::ChildExited
        add_log "The child process exited!"
      rescue => e
        add_log e.message
      end
    end
  end

  def add_log text
    prev_log = @log_box.text
    @log_box.text = "#{prev_log} \n #{text}"
  end
end
