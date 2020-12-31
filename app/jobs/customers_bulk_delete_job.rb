class CustomersBulkDeleteJob < ApplicationJob
  queue_as :default

  def perform(args)
    logs = []
    ids = args[:ids]
    account_id = args[:account_id]
    user_id = args[:user_id]
    total = ids.size

    account = QboAccount.find(account_id)
    qbo_api = QboApi.new(access_token: account.access_token, realm_id: account.realm_id)


    ids.each_with_index do |id, idx|
      begin
        qbo_api.deactivate(:customer, id: id)
        logs << { id: id, status: 'success', message: '' }
      rescue => e
        logs << { id: id, status: 'failed', message: e.message }
      end
      percent = ((idx + 1) * 100) / total
      ActionCable.server.broadcast "bulk_delete_channel_#{@job_id}", { percent: percent >= 100 ? 99 : percent}
    end

    account.activities.create(
      action: Activity.actions[:bulk_archive],
      entity_name: 'Customer',
      third_party_ids: ids,
      logs: logs,
      user_id: user_id,
      job_id: @job_id
    )

    ActionCable.server.broadcast "bulk_delete_channel_#{@job_id}", { percent: 100 }
  end
end
