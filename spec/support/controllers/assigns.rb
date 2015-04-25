module Controllers
  module Assigns
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def assigns(key = nil, &block)
        if block.present?
          if key.blank?
            describe 'assigns' do
              class_exec &block
            end
          else
            describe "@#{key}" do
              subject {assigns key}

              class_exec &block
            end
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Assigns, type: :controller
end
