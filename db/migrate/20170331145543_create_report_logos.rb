class CreateReportLogos < ActiveRecord::Migration[5.2]
  def change
    create_table :report_logos do |t|
      t.string :name
      t.string :report_logo

      t.timestamps
    end
  end
end
