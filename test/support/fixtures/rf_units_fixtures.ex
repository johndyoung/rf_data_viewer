defmodule RFDataViewer.RFUnitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RFDataViewer.RFUnits` context.
  """

  @doc """
  Generate a rf_unit.
  """
  def rf_unit_fixture(attrs \\ %{}) do
    {:ok, rf_unit} =
      attrs
      |> Enum.into(%{
        description: "some description",
        manufacturer: "some manufacturer",
        name: "some name"
      })
      |> RFDataViewer.RFUnits.create_rf_unit()

    rf_unit
  end

  @doc """
  Generate a rf_unit_serial_number.
  """
  def rf_unit_serial_number_fixture(attrs \\ %{}) do
    {:ok, rf_unit_serial_number} =
      attrs
      |> Enum.into(%{
        serial_number: "some serial_number"
      })
      |> RFDataViewer.RFUnits.create_rf_unit_serial_number()

    rf_unit_serial_number
  end
end
