class AddExchToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :exch, :string
  end
end
