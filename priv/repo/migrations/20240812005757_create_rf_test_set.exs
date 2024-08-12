defmodule RFDataViewer.Repo.Migrations.CreateRfTestSet do
  use Ecto.Migration

  def change do
    create table(:rf_test_set) do
      add :name, :string
      add :description, :text
      add :location, :string
      add :date, :utc_datetime
      add :rf_unit_serial_number_id, references(:rf_unit_serial_numbers, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rf_test_set, [:rf_unit_serial_number_id])
  end
end
