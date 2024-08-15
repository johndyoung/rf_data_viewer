defmodule RFDataViewer.Repo.Migrations.RfTestSetNameLocationDateUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:rf_test_set, [:name, :location, :date, :rf_unit_serial_number_id])
  end
end
