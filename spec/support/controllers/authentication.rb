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
            before do |example|
              current_user.update_column :role, role if respond_to?(:role)

              sign_in current_user

              request unless example.metadata[:defer_request]
            end

            class_exec &block
          end
        end

        context 'unauthenticated' do
          before {request}

          it 'exhibits standard unauthenticated behavior' do
            # response
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(new_user_session_path)

            # flash
            expect(subject).to set_flash[:alert].to('You need to sign in or sign up before continuing.')
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Authentication, type: :controller
end
