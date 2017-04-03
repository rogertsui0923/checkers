class GameChannel < ApplicationCable::Channel
  def subscribed
    @id = params[:id]
    stop_all_streams
    stream_from "game#{@id}"
    puts '#################################'
    puts "Subscribe to stream game#{@id}"
    puts '#################################'
  end

  def unsubscribed
    stop_all_streams
  end
end
