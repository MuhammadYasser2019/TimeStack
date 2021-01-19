class CreateCaseStudies < ActiveRecord::Migration[5.2]
  def change
    create_table :case_studies do |t|
      t.string :case_study_name
      t.text   :case_study_data

      t.timestamps
    end
  end
end
