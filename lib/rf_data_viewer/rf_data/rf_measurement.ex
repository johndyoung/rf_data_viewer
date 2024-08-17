defmodule RFDataViewer.RFData.RFMeasurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_measurements" do
    field :type, :string
    field :frequency, :integer
    field :value, :float
    belongs_to :data_set, RFDataViewer.RFData.RFDataSet, foreign_key: :rf_data_set_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_measurement, attrs) do
    rf_measurement
    |> cast(attrs, [:type, :frequency, :value, :rf_data_set_id])
    |> validate_required([:type, :frequency, :value, :rf_data_set_id])
  end
end
