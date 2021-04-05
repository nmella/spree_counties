module Spree
  module Api
    class CountiesController < Spree::Api::BaseController
      # skip_before_action :set_expiry
      # skip_before_action :check_for_user_or_api_key
      skip_before_action :authenticate_user

      def index
        @counties = scope.ransack(params[:q]).result.
                    includes(:state).order('name ASC')

        @counties = @counties.page(params[:page]).per(params[:per_page]) if params[:page] || params[:per_page]

        county = @counties.last
        if stale?(county)
          # respond_with(@counties)
          render json: { counties: @counties }
        end
      end

      def show
        @county = scope.find(params[:id])
        respond_with(@county)
      end

      private

      def scope
        if params[:state_id]
          @state = Spree::State.accessible_by(current_ability, :read).find(params[:state_id])
          @state.counties.accessible_by(current_ability, :read)
        else
          Spree::County.accessible_by(current_ability, :read)
        end
      end
    end
  end
end
