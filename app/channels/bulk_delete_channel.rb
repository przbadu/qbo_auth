class BulkDeleteChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "bulk_delete_channel_#{params[:job_id]}"
    stream_from 'bulk_delete_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
