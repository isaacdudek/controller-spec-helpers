module Controllers
  module Attributes
    extend ActiveSupport::Concern

    included do
      extend DSL

      let(:attributes) {{}}
    end

    module DSL
      def valid_attributes(&block)
        let :valid_attributes, &block if block.present?
      end

      def invalid_attributes(&block)
        let :invalid_attributes, &block if block.present?
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Attributes, type: :controller
end
