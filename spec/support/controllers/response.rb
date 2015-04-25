module Controllers
  module Response
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def response(&block)
        if block.present?
          describe 'response' do
            subject {response}

            class_exec &block
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Response, type: :controller
end
