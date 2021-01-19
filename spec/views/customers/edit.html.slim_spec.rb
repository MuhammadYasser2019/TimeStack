require 'rails_helper'

RSpec.describe "customers/edit", type: :view do
  before(:each) do
    @customer = assign(:customer, Customer.create!(
      :name => "MyString",
      :address => "MyString",
      :city => "MyString",
      :state => "MyString",
      :zipcode => "MyString"
    ))
  end

  it "renders the edit customer form" do
    render

    assert_select "form[action=?][method=?]", customer_path(@customer), "post" do

      assert_select "input#customer_name[name=?]", "customer[name]"

      assert_select "input#customer_address[name=?]", "customer[address]"

      assert_select "input#customer_city[name=?]", "customer[city]"

      assert_select "input#customer_state[name=?]", "customer[state]"

      assert_select "input#customer_zipcode[name=?]", "customer[zipcode]"
    end
  end
end
