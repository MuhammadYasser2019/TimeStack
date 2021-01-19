require 'rails_helper'

RSpec.describe "archived_time_entries/show", type: :view do
  before(:each) do
    @archived_time_entry = assign(:archived_time_entry, ArchivedTimeEntry.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
