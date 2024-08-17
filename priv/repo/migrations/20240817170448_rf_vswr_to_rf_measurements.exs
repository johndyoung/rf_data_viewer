defmodule RFDataViewer.Repo.Migrations.RfVswrToRfMeasurements do
  use Ecto.Migration

  def up do
    # simple data migration because this would still be a "development stage" migration without production implications with a small ephemeral dataset
    RFDataViewer.Repo.query!(
      "INSERT INTO rf_measurements (type, frequency, value, rf_data_set_id, inserted_at, updated_at) SELECT 'vswr', frequency, vswr, rf_data_set_id, inserted_at, updated_at FROM rf_vswr"
    )

    RFDataViewer.Repo.delete_all("rf_vswr")
  end

  def down do
    RFDataViewer.Repo.query(
      "INSERT INTO rf_vswr (frequency, vswr, rf_data_set_id, inserted_at, updated_at) SELECT m.frequency, m.value, m.rf_data_set_id, m.inserted_at, updated_at FROM rf_measurements as m WHERE m.type = 'vswr'"
    )

    RFDataViewer.Repo.query("DELETE FROM rf_measurements WHERE type = 'vswr'")
  end
end
