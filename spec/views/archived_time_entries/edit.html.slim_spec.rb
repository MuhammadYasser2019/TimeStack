require 'rails_helper'

RSpec.describe "archived_time_entries/edit", type: :view do
  before(:each) do
    @archived_time_entry = assign(:archived_time_entry, ArchivedTimeEntry.create!())
  end

  it "renders the edit archived_time_entry form" do
    render

    assert_select "form[action=?][method=?]", archived_time_entry_path(@archived_time_entry), "post" do
    end
  end
end
