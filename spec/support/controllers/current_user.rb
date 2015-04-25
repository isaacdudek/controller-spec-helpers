module Controllers
  module CurrentUser
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def current_user(&block)
        let :current_user, &block if block.present?
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::CurrentUser, type: :controller
end
