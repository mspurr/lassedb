class RemoveMcapFromCompanies < ActiveRecord::Migration[5.0]
  def change
    remove_column :companies, :mcap, :string
  end
end
