module Pagination
  def paginated_collection(*records)
    paginatable_array = Kaminari.paginate_array(records, total_count: records.size + 1)

    paginatable_array.page(1).per(records.size)
  end
end

shared_examples 'pagination', pagination: true do
  it 'displays pagination' do
    render

    assert_select 'nav > ul.pagination'
  end
end

RSpec.configure do |config|
  config.include Pagination, type: :view
end
