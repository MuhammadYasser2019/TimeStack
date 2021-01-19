require 'rails_helper'

RSpec.describe "time_entries/edit", type: :view do
  before(:each) do
    @time_entry = assign(:time_entry, TimeEntry.create!(
      :hours => 1,
      :comments => "MyString",
      :task => nil,
      :week => nil,
      :user => nil
    ))
  end

  it "renders the edit time_entry form" do
    render

    assert_select "form[action=?][method=?]", time_entry_path(@time_entry), "post" do

      assert_select "input#time_entry_hours[name=?]", "time_entry[hours]"

      assert_select "input#time_entry_comments[name=?]", "time_entry[comments]"

      assert_select "input#time_entry_task_id[name=?]", "time_entry[task_id]"

      assert_select "input#time_entry_week_id[name=?]", "time_entry[week_id]"

      assert_select "input#time_entry_user_id[name=?]", "time_entry[user_id]"
    end
  end
end
