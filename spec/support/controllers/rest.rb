module Controllers
  module REST
    extend ActiveSupport::Concern

    def resource_class
      described_class.controller_name.classify.constantize
    end

    def collection
      send self.class.collection_instance_variable_name
    end

    def element
      send self.class.element_instance_variable_name
    end

    def collection_path
      send "#{self.class.collection_instance_variable_name}_path"
    end

    def template_path(template_name)
      File.join described_class.controller_path, template_name
    end

    included do
      extend DSL
    end

    module DSL
      def restful(action, options = {})
        send "restful_#{action}", options
      end

      def collection_instance_variable_name
        described_class.controller_name
      end

      def element_instance_variable_name
        collection_instance_variable_name.singularize
      end

      private

      def restful_index(options = {})
        response do
          it {should have_http_status(:ok)}
          it {should render_template(template_path('index'))}
        end

        assigns do
          assigns collection_instance_variable_name do
            it {should be_an(ActiveRecord::Relation)}
            it {should all(be_a(resource_class))}
            it {should match_array(collection)}
          end
        end

        flash do
          it {should_not set_flash}
        end
      end

      def restful_show(options = {})
        response do
          it {should have_http_status(:ok)}
          it {should render_template(template_path('show'))}
        end

        assigns do
          assigns element_instance_variable_name do
            it {should be_a(resource_class)}
            it {should eq(element)}
          end
        end

        flash do
          it {should_not set_flash}
        end
      end

      def restful_new(options = {})
        response do
          it {should have_http_status(:ok)}
          it {should render_template(template_path('new'))}
        end

        assigns do
          assigns element_instance_variable_name do
            it {should be_a_new(resource_class)}
          end
        end

        flash do
          it {should_not set_flash}
        end
      end

      def restful_create(options = {})
        options.reverse_merge! valid_params: true

        if options[:valid_params]
          response do
            it {should have_http_status(:redirect)}
            it {should redirect_to(resource_class.last)}
          end

          assigns do
            assigns element_instance_variable_name do
              it {should be_a(resource_class)}
              it {should be_persisted}
            end
          end

          flash do
            it {should set_flash[:notice]}
          end
        else
          response do
            it {should have_http_status(:ok)}
            it {should render_template(template_path('new'))}
          end

          assigns do
            assigns element_instance_variable_name do
              it {should be_a_new(resource_class)}
            end
          end

          flash do
            it {should_not set_flash}
          end
        end
      end

      def restful_edit(options = {})
        response do
          it {should have_http_status(:ok)}
          it {should render_template(template_path('edit'))}
        end

        assigns do
          assigns element_instance_variable_name do
            it {should be_a(resource_class)}
            it {should eq(element)}
          end
        end

        flash do
          it {should_not set_flash}
        end
      end

      def restful_update(options = {})
        options.reverse_merge! valid_params: true

        if options[:valid_params]
          response do
            it {should have_http_status(:redirect)}
            it {should redirect_to(element)}
          end

          assigns do
            assigns element_instance_variable_name do
              it {should be_a(resource_class)}
              it {should eq(element)}
            end
          end

          flash do
            it {should set_flash[:notice]}
          end
        else
          response do
            it {should have_http_status(:ok)}
            it {should render_template(template_path('edit'))}
          end

          assigns do
            assigns element_instance_variable_name do
              it {should be_a(resource_class)}
              it {should eq(element)}
            end
          end

          flash do
            it {should_not set_flash}
          end
        end
      end

      def restful_destroy(options = {})
        response do
          it {should have_http_status(:redirect)}
          it {should redirect_to(collection_path)}
        end

        assigns do
          assigns element_instance_variable_name do
            it {should be_a(resource_class)}
            it {should eq(element)}
            it {should be_destroyed}
          end
        end

        flash do
          it {should set_flash[:notice]}
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::REST, type: :controller
end
