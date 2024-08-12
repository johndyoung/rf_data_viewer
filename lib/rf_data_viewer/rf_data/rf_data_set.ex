defmodule RFDataViewer.RFData.RFDataSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_data_set" do
    field :name, :string
    field :date, :utc_datetime
    field :description, :string
    belongs_to :rf_test_set, RFDataViewer.RFData.RFTestSet
    has_many :rf_gain, RFDataViewer.RFData.RFGain

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_data_set, attrs) do
    rf_data_set
    |> cast(attrs, [:name, :description, :date, :rf_test_set_id])
    |> validate_required([:name, :description, :date, :rf_test_set_id])
  end
end
