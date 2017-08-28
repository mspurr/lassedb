class AddTitleToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :title, :string
  end
end
