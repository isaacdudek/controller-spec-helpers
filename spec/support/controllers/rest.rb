module Controllers
  module REST
    extend ActiveSupport::Concern

    def resource_class
      element_name.classify.constantize
    end

    def collection_name
      described_class.controller_name
    end

    def element_name
      collection_name.singularize
    end

    def collection
      send collection_name
    end

    def element
      send element_name
    end

    def collection_path
      send "#{collection_name}_path"
    end

    def template_path(template_name)
      File.join described_class.controller_path, template_name
    end

    included do
      extend DSL
    end

    module DSL
      def restful(action, &block)
        send "restful_#{action}", &block
      end

      private

      def restful_index(&block)
        it 'exhibits RESTful index behavior' do
          # response
          expect(response).to have_http_status(:ok)
          expect(response).to render_template(template_path('index'))

          # assigns
          expect(assigns(collection_name)).to be_an(ActiveRecord::Relation)
          expect(assigns(collection_name)).to all(be_a(resource_class))
          expect(assigns(collection_name)).to match_array(collection)

          # flash
          expect(subject).to_not set_flash
        end
      end

      def restful_show(&block)
        it 'exhibits RESTful show behavior' do
          # response
          expect(response).to have_http_status(:ok)
          expect(response).to render_template(template_path('show'))

          # assigns
          expect(assigns(element_name)).to be_a(resource_class)
          expect(assigns(element_name)).to eq(element)

          # flash
          expect(subject).to_not set_flash
        end
      end

      def restful_new(&block)
        it 'exhibits RESTful new behavior' do
          # response
          expect(response).to have_http_status(:ok)
          expect(response).to render_template(template_path('new'))

          # assigns
          expect(assigns(element_name)).to be_a_new(resource_class)

          # flash
          expect(subject).to_not set_flash
        end
      end

      def restful_create(&block)
        context 'valid' do
          let(:attributes) {valid_attributes}

          it 'exhibits RESTful valid create behavior', :defer_request do
            # request
            expect {request}.to change(resource_class, :count).by(1)

            # response
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(resource_class.last)

            # assigns
            expect(assigns(element_name)).to be_a(resource_class)
            expect(assigns(element_name)).to be_persisted

            # flash
            expect(subject).to set_flash[:notice]
          end

          class_exec &block if block.present?
        end

        context 'invalid' do
          let(:attributes) {invalid_attributes}

          it 'exhibits RESTful invalid create behavior', :defer_request do
            # request
            expect {request}.to_not change(resource_class, :count)

            # response
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(template_path('new'))

            # assigns
            expect(assigns(element_name)).to be_a_new(resource_class)

            # flash
            expect(subject).to_not set_flash
          end
        end
      end

      def restful_edit(&block)
        it 'exhibits RESTful edit behavior' do
          # response
          expect(response).to have_http_status(:ok)
          expect(response).to render_template(template_path('edit'))

          # assigns
          expect(assigns(element_name)).to be_a(resource_class)
          expect(assigns(element_name)).to eq(element)

          # flash
          expect(subject).to_not set_flash
        end
      end

      def restful_update(&block)
        context 'valid' do
          let(:attributes) {valid_attributes}

          it 'exhibits RESTful valid update behavior', :defer_request do
            # request
            expect {request}.to_not change(resource_class, :count)

            # response
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(element)

            # assigns
            expect(assigns(element_name)).to be_a(resource_class)
            expect(assigns(element_name)).to eq(element)

            # flash
            expect(subject).to set_flash[:notice]
          end

          class_exec &block if block.present?
        end

        context 'invalid' do
          let(:attributes) {invalid_attributes}

          it 'exhibits RESTful invalid update behavior', :defer_request do
            # request
            expect {request}.to_not change(resource_class, :count)

            # response
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(template_path('edit'))

            # assigns
            expect(assigns(element_name)).to be_a(resource_class)
            expect(assigns(element_name)).to eq(element)

            # flash
            expect(subject).to_not set_flash
          end
        end
      end

      def restful_destroy(&block)
        it 'exhibits RESTful destroy behavior', :defer_request do
          # request
          expect {request}.to change(resource_class, :count).by(-1)

          # response
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(collection_path)

          # assigns
          expect(assigns(element_name)).to be_a(resource_class)
          expect(assigns(element_name)).to eq(element)
          expect(assigns(element_name)).to be_destroyed

          # flash
          expect(subject).to set_flash[:notice]
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::REST, type: :controller
end
