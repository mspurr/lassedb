class AddApiTitleToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :apiTitle, :string
  end
end
