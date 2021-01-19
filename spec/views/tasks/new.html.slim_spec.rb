require 'rails_helper'

RSpec.describe "tasks/new", type: :view do
  before(:each) do
    assign(:task, Task.new(
      :code => "MyString",
      :description => "MyString",
      :project => nil
    ))
  end

  it "renders new task form" do
    render

    assert_select "form[action=?][method=?]", tasks_path, "post" do

      assert_select "input#task_code[name=?]", "task[code]"

      assert_select "input#task_description[name=?]", "task[description]"

      assert_select "input#task_project_id[name=?]", "task[project_id]"
    end
  end
end
