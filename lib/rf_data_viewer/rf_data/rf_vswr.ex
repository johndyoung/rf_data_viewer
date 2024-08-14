defmodule RFDataViewer.RFData.RFVswr do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_vswr" do
    field :frequency, :integer
    field :vswr, :float
    belongs_to :data_set, RFDataViewer.RFData.RFDataSet, foreign_key: :rf_data_set_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_vswr, attrs) do
    rf_vswr
    |> cast(attrs, [:frequency, :vswr, :rf_data_set_id])
    |> validate_required([:frequency, :vswr, :rf_data_set_id])
  end
end
