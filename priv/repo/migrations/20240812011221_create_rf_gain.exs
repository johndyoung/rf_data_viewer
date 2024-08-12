defmodule RFDataViewer.Repo.Migrations.CreateRfGain do
  use Ecto.Migration

  def change do
    create table(:rf_gain) do
      add :frequency, :integer
      add :gain, :float
      add :rf_data_set_id, references(:rf_data_set, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rf_gain, [:rf_data_set_id])
  end
end
