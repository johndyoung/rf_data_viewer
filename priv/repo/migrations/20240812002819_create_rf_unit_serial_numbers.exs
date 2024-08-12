defmodule RFDataViewer.Repo.Migrations.CreateRfUnitSerialNumber do
  use Ecto.Migration

  def change do
    create table(:rf_unit_serial_numbers) do
      add :serial_number, :string
      add :rf_unit_id, references(:rf_units, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rf_unit_serial_numbers, [:rf_unit_id])
  end
end
