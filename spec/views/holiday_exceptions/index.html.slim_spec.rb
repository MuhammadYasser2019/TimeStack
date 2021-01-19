require 'rails_helper'

RSpec.describe "holiday_exceptions/index", type: :view do
  before(:each) do
    assign(:holiday_exceptions, [
      HolidayException.create!(
        :user_id => 2,
        :project_id => 3,
        :customer_id => 4,
        :holiday_id => 5
      ),
      HolidayException.create!(
        :user_id => 2,
        :project_id => 3,
        :customer_id => 4,
        :holiday_id => 5
      )
    ])
  end

  it "renders a list of holiday_exceptions" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
