class Api::V1::StatisticsController < Api::V1::BaseController
  def index
    @statistics = Statistic.joins(:ethnicity).includes(:district, :ethnicity).where(
      ethnicities: { name: statistic_filter_params[:ethnicity_name] },
      year: statistic_filter_params[:year],
      type: Statistic::VALID_TYPES[statistic_filter_params[:action_type]]
    )
  end

  private

  def statistic_filter_params
    params.permit(:ethnicity_name, :year, :action_type)
  end
end
