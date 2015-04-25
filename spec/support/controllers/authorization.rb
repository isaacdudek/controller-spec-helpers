module Controllers
  module Authorization
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def authorized(&block)
        if block.present?
          context 'authorized' do
            context metadata[:current_role] do
              let(:role) {current_user.role}

              class_exec &block
            end
          end
        end

        context 'unauthorized' do
          (User::ROLES - [metadata[:current_role]]).each do |role|
            context role do
              let(:role) {role}

              response do
                it {should have_http_status(:redirect)}
                it {should redirect_to(dashboard_path)}
              end

              flash do
                it {should set_flash[:alert].to('You are not authorized to view this page.')}
              end
            end
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Authorization, type: :controller
end
