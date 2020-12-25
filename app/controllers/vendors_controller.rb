class VendorsController < ApplicationController
  def index
    @vendors = qbo_api.all(:vendors)
    render json: @vendors.as_json
  end
end
