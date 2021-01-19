require 'rails_helper'

RSpec.describe "holiday_exceptions/show", type: :view do
  before(:each) do
    @holiday_exception = assign(:holiday_exception, HolidayException.create!(
      :user_id => 2,
      :project_id => 3,
      :customer_id => 4,
      :holiday_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end
