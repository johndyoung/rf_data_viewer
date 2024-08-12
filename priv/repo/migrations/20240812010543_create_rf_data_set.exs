defmodule RFDataViewer.Repo.Migrations.CreateRfDataSet do
  use Ecto.Migration

  def change do
    create table(:rf_data_set) do
      add :name, :string
      add :description, :text
      add :date, :utc_datetime
      add :rf_test_set_id, references(:rf_test_set, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rf_data_set, [:rf_test_set_id])
  end
end
