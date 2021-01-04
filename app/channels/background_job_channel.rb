class BackgroundJobChannel < ApplicationCable::Channel
  def subscribed
    stream_from "background_job_channel_#{params[:room]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
