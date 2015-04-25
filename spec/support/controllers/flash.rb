module Controllers
  module Flash
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def flash(&block)
        if block.present?
          describe 'flash' do
            class_exec &block
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Flash, type: :controller
end
