module Controllers
  module Sortable
    extend ActiveSupport::Concern

    included do
      extend DSL
    end

    module DSL
      def sortable(collection_name, sort_options, &block)
        raise "sort_options are required" unless sort_options.present?
        prefix = sort_options[:prefix].present? ? "#{sort_options[:prefix]}_" : ""
        attr_map =
          if sort_options[:attributes].is_a? Hash
            sort_options[:attributes]
          else
            Hash[sort_options[:attributes].map{|attr| [attr, "asc"]}]
          end
        attr_map.each do |sort, direction|
          context "sorted by #{sort}" do
            request { 
              get :index,
              {sort: "#{prefix}#{sort}", direction: "#{prefix}#{direction}"}
            }
            it "returns valid elements" do
              request
              expect(assigns(collection_name).map(&:id)).to be
            end
          end
        end
        class_exec(&block) if block.present?
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::Sortable, type: :controller
  config.before type: :controller do
    controller.extend Sortable
  end
end
