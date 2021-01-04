class CustomersBulkDeleteJob < ApplicationJob
  queue_as :default
  sidekiq_options :retry => 5

  def perform(args)
    logs = []
    ids = args[:ids]
    account_id = args[:account_id]
    user_id = args[:user_id]
    total = ids.size
    batch_size = 30

    account = QboAccount.find(account_id)
    qbo_api = QboApi.new(access_token: account.access_token, realm_id: account.realm_id)

    payload = {BatchItemRequest: []}
    ids.in_groups_of(batch_size).each_with_index do |group_ids, idx|
      group_ids.each do |id_with_name|
        next if id_with_name.nil?

        name, id = id_with_name.split('::')
        payload[:BatchItemRequest] << {
          "bId": "bid#{idx}:::#{id}",
          "operation": "update",
          "Customer": {
            'Id': id.to_s,
            'DisplayName': name,
            'Active': false
          }
        }
      end

      response = qbo_api.batch(payload)
      # prepare logs
      response['BatchItemResponse'].each do |r|
        response_id = r['bId'].split(':::').last
        errors = r.dig('Fault', 'Error')
        if errors.present?
          logs << { id: response_id, status: 'failed', message: errors.map{ |e| e['Detail'] }.join(', ') }
        else
          logs << { id: response_id, status: 'success', message: ''}
        end
      end

      percent = ((idx + 1) * batch_size * 100) / total
      ActionCable.server.broadcast "background_job_channel_#{@job_id}", { percent: percent >= 100 ? 99 : percent}
    end

    account.activities.create(
      action: Activity.actions[:bulk_archive],
      entity_name: 'Customer',
      third_party_ids: ids,
      logs: logs,
      user_id: user_id,
      job_id: @job_id
    )
    ActionCable.server.broadcast "background_job_channel_#{@job_id}", { percent: 100}
  end
end
