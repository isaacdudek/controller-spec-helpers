module Controllers
  module Authentication
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def authenticated(&block)
        if block.present?
          context 'authenticated' do
            before do
              current_user.update_column :role, role if respond_to?(:role)

              sign_in current_user

              request
            end

            class_exec &block
          end
        end

        context 'unauthenticated' do
          before {request}

          response do
            it {should have_http_status(:redirect)}
            it {should redirect_to(new_user_session_path)}
          end

          flash do
            it {should set_flash[:alert].to('You need to sign in or sign up before continuing.')}
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Authentication, type: :controller
end
