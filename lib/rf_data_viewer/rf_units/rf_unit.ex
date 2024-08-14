defmodule RFDataViewer.RFUnits.RFUnit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rf_units" do
    field :name, :string
    field :description, :string
    field :manufacturer, :string
    has_many :serial_numbers, RFDataViewer.RFUnits.RFUnitSerialNumber

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rf_unit, attrs) do
    rf_unit
    |> cast(attrs, [:name, :manufacturer, :description])
    |> validate_required([:name, :manufacturer, :description])
  end
end
