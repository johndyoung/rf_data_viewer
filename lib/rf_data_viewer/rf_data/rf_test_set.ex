defmodule RFDataViewer.RFData.RFTestSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_test_set" do
    field :name, :string
    field :date, :date
    field :description, :string
    field :location, :string
    belongs_to :serial_number, RFDataViewer.RFUnits.RFUnitSerialNumber, foreign_key: :rf_unit_serial_number_id
    has_many :data_sets, RFDataViewer.RFData.RFDataSet

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_test_set, attrs) do
    rf_test_set
    |> cast(attrs, [:name, :description, :location, :date, :rf_unit_serial_number_id])
    |> validate_required([:name, :description, :location, :date, :rf_unit_serial_number_id])
    |> unique_constraint([:name, :location, :date, :rf_unit_serial_number_id])
  end
end
