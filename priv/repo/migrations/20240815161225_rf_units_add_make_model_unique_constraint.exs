defmodule RFDataViewer.Repo.Migrations.RfUnitsAddMakeModelUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:rf_units, [:name, :manufacturer])
  end
end
