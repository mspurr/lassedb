class AddMcapToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :mcap, :float
  end
end
