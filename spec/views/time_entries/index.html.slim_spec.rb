require 'rails_helper'

RSpec.describe "time_entries/index", type: :view do
  before(:each) do
    assign(:time_entries, [
      TimeEntry.create!(
        :hours => 1,
        :comments => "Comments",
        :task => nil,
        :week => nil,
        :user => nil
      ),
      TimeEntry.create!(
        :hours => 1,
        :comments => "Comments",
        :task => nil,
        :week => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of time_entries" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Comments".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
