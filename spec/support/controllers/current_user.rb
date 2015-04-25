module Controllers
  module CurrentUser
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def current_user(&block)
        if block.present?
          let :current_user, &block

          metadata[:current_role] = block.call.role
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::CurrentUser, type: :controller
end
