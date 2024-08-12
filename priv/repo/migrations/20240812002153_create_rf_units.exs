defmodule RFDataViewer.Repo.Migrations.CreateRfUnits do
  use Ecto.Migration

  def change do
    create table(:rf_units) do
      add :name, :string
      add :manufacturer, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
