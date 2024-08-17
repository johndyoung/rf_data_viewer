defmodule RFDataViewer.RFDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RFDataViewer.RFData` context.
  """

  @doc """
  Generate a rf_test_set.
  """
  def rf_test_set_fixture(attrs \\ %{}) do
    rf_unit_sn = RFDataViewer.RFUnitsFixtures.rf_unit_serial_number_fixture()

    {:ok, rf_test_set} =
      attrs
      |> Enum.into(%{
        date: ~U[2024-08-11 00:57:00Z],
        description: "some description",
        location: "some location",
        name: "some name"
      })
      |> then(fn test_set -> RFDataViewer.RFData.create_rf_test_set(rf_unit_sn, test_set) end)

    rf_test_set
  end

  @doc """
  Generate a rf_data_set.
  """
  def rf_data_set_fixture(attrs \\ %{}) do
    test_set = rf_test_set_fixture()

    {:ok, rf_data_set} =
      attrs
      |> Enum.into(%{
        date: ~U[2024-08-11 01:05:00Z],
        description: "some description",
        name: "some name"
      })
      |> then(fn data_set -> RFDataViewer.RFData.create_rf_data_set(test_set, data_set) end)

    rf_data_set
  end

  @doc """
  Generate a rf_measurements entry.
  """
  def rf_measurement_fixture(attrs \\ %{}) do
    data_set = rf_data_set_fixture()

    {:ok, rf_measurement} =
      attrs
      |> Enum.into(%{
        type: "gain",
        frequency: 42,
        value: 120.5
      })
      |> then(fn meas -> RFDataViewer.RFData.create_rf_measurement(data_set, meas) end)

      rf_measurement
  end
end
