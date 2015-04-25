module Controllers
  module Request
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def request(&block)
        let :request, &block if block.present?
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Request, type: :controller
end
