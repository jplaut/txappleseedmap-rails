class Api::V1::DistrictsController < Api::V1::BaseController
  def index
    @districts = District.all
  end
end
