require 'rails_helper'

RSpec.describe "tasks/edit", type: :view do
  before(:each) do
    @task = assign(:task, Task.create!(
      :code => "MyString",
      :description => "MyString",
      :project => nil
    ))
  end

  it "renders the edit task form" do
    render

    assert_select "form[action=?][method=?]", task_path(@task), "post" do

      assert_select "input#task_code[name=?]", "task[code]"

      assert_select "input#task_description[name=?]", "task[description]"

      assert_select "input#task_project_id[name=?]", "task[project_id]"
    end
  end
end
