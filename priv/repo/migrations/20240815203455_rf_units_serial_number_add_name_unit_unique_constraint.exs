defmodule RFDataViewer.Repo.Migrations.RfUnitsSerialNumberAddNameUnitUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:rf_unit_serial_numbers, [:serial_number, :rf_unit_id])
  end
end
