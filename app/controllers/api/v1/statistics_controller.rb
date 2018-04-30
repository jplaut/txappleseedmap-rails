class Api::V1::StatisticsController < Api::V1::BaseController
  def index
    @statistics = Statistic.where(statistic_filter_params[:statistics])
  end

  private

  def statistic_filter_params
    params.require(:statistics).permit()
  end
end
