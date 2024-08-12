defmodule RFDataViewer.RFUnits.RFUnitSerialNumber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_unit_serial_numbers" do
    field :serial_number, :string
    belongs_to :rf_unit, RFDataViewer.RFUnits.RFUnit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_unit_serial_number, attrs) do
    rf_unit_serial_number
    |> cast(attrs, [:serial_number, :rf_unit_id])
    |> validate_required([:serial_number, :rf_unit_id])
  end
end
