require 'rails_helper'

RSpec.describe "archived_time_entries/new", type: :view do
  before(:each) do
    assign(:archived_time_entry, ArchivedTimeEntry.new())
  end

  it "renders new archived_time_entry form" do
    render

    assert_select "form[action=?][method=?]", archived_time_entries_path, "post" do
    end
  end
end
