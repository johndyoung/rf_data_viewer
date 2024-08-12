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
  Generate a rf_gain.
  """
  def rf_gain_fixture(attrs \\ %{}) do
    data_set = rf_data_set_fixture()

    {:ok, rf_gain} =
      attrs
      |> Enum.into(%{
        frequency: 42,
        gain: 120.5
      })
      |> then(fn gain -> RFDataViewer.RFData.create_rf_gain(data_set, gain) end)

    rf_gain
  end

  @doc """
  Generate a rf_vswr.
  """
  def rf_vswr_fixture(attrs \\ %{}) do
    data_set = rf_data_set_fixture()

    {:ok, rf_vswr} =
      attrs
      |> Enum.into(%{
        frequency: 42,
        vswr: 120.5
      })
      |> then(fn vswr -> RFDataViewer.RFData.create_rf_vswr(data_set, vswr) end)

    rf_vswr
  end
end
