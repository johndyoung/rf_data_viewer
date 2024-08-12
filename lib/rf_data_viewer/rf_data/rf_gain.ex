defmodule RFDataViewer.RFData.RFGain do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_gain" do
    field :frequency, :integer
    field :gain, :float
    belongs_to :rf_data_set, RFDataViewer.RFData.RFDataSet

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_gain, attrs) do
    rf_gain
    |> cast(attrs, [:frequency, :gain, :rf_data_set_id])
    |> validate_required([:frequency, :gain, :rf_data_set_id])
  end
end
