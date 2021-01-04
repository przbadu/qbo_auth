require 'csv'

class CustomersExportJob < ApplicationJob
  queue_as :default
  sidekiq_options :retry => 5

  def perform(args)
    ids = args[:ids]
    account_id = args[:account_id]
    user_id = args[:user_id]
    file = "#{Rails.root}/public/#{Time.current.strftime('%Y-%m-%d_%H-%M-%S')}-customers.csv"

    headers = %w{Id Name Company Email Phone Mobile Fax Website Street City State ZIP Country OpeningBalance OpeningBalanceDate TaxResaleNo CustomerType Currency Job Taxable}

    account = QboAccount.find(account_id)
    qbo_api = QboApi.new(access_token: account.access_token, realm_id: account.realm_id)

    # qbo_api.all(:customer, select: "Select * from Customer where Id IN (?)", ids.join(', ')).each do |customer|
    # TODO: apply filters
    # Date range
    count = 0
    CSV.open(file, 'w', write_headers: true, headers: headers) do |csv|
      qbo_api.all(:customer, max: 2).each do |customer|
      headers = %w{Id Name Company Email Phone Mobile Fax Website Street City State ZIP Country OpeningBalance OpeningBalanceDate CustomerType Currency Job Taxable}

        csv << [
          customer['Id'],
          customer['DisplayName'],
          customer['CompanyName'],
          customer.dig('PrimaryEmailAddr', 'Address'),
          customer.dig('PrimaryPhone', 'FreeFormNumber'),
          customer.dig('Mobile', 'FreeFormNumber'),
          customer.dig('Fax', 'FreeFormNumber'),
          customer.dig('WebAddr', 'URI'),
          customer.dig('BillAddr', 'Line1'), # Line1, Line2, Line3, Line4
          customer.dig('BillAddr', 'City'),
          customer.dig('BillAddr', 'CountrySubDivisionCode'), # CountrySubDivisionCode, State, Province, Region
          customer.dig('BillAddr', 'PostalCode'), # PostalCode, Zip
          customer.dig('BillAddr', 'Country'),
          customer.dig('Balance'),
          customer.dig('OpeningBalanceDate'),
          customer.dig('CustomerTypeRef', 'value'),
          customer.dig('CurrencyRef', 'value'), # don't import it
          customer.dig('Job'),
          customer.dig('Taxable')
        ]

        count += 1
        ActionCable.server.broadcast "background_job_channel_#{@job_id}", { count: count }
      end
    end

    account.activities.create(
      action: Activity.actions[:export],
      entity_name: 'Customer',
      third_party_ids: [],
      logs: [{ total_export_count: count }],
      user_id: user_id,
      job_id: @job_id
    )
    ActionCable.server.broadcast "background_job_channel_#{@job_id}", { percent: 100, downloadLink: file }
  end
end
