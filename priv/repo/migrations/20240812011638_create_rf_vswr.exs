defmodule RFDataViewer.Repo.Migrations.CreateRfVswr do
  use Ecto.Migration

  def change do
    create table(:rf_vswr) do
      add :frequency, :integer
      add :vswr, :float
      add :rf_data_set_id, references(:rf_data_set, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rf_vswr, [:rf_data_set_id])
  end
end
