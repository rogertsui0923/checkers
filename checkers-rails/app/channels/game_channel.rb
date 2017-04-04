class GameChannel < ApplicationCable::Channel
  def subscribed
    @id = params[:id]
    stop_all_streams
    stream_from "game#{@id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
