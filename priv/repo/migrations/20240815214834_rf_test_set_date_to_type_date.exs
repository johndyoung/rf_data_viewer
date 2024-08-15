defmodule RFDataViewer.Repo.Migrations.RfTestSetDateToTypeDate do
  use Ecto.Migration

  def change do
    alter table(:rf_test_set) do
      modify :date, :date
    end
  end
end
