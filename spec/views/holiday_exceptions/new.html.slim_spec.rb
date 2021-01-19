require 'rails_helper'

RSpec.describe "holiday_exceptions/new", type: :view do
  before(:each) do
    assign(:holiday_exception, HolidayException.new(
      :user_id => 1,
      :project_id => 1,
      :customer_id => 1,
      :holiday_id => 1
    ))
  end

  it "renders new holiday_exception form" do
    render

    assert_select "form[action=?][method=?]", holiday_exceptions_path, "post" do

      assert_select "input#holiday_exception_user_id[name=?]", "holiday_exception[user_id]"

      assert_select "input#holiday_exception_project_id[name=?]", "holiday_exception[project_id]"

      assert_select "input#holiday_exception_customer_id[name=?]", "holiday_exception[customer_id]"

      assert_select "input#holiday_exception_holiday_id[name=?]", "holiday_exception[holiday_id]"
    end
  end
end
