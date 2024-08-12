defmodule RFDataViewer.RFDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RFDataViewer.RFData` context.
  """

  @doc """
  Generate a rf_test_set.
  """
  def rf_test_set_fixture(attrs \\ %{}) do
    {:ok, rf_test_set} =
      attrs
      |> Enum.into(%{
        date: ~U[2024-08-11 00:57:00Z],
        description: "some description",
        location: "some location",
        name: "some name"
      })
      |> RFDataViewer.RFData.create_rf_test_set()

    rf_test_set
  end

  @doc """
  Generate a rf_data_set.
  """
  def rf_data_set_fixture(attrs \\ %{}) do
    {:ok, rf_data_set} =
      attrs
      |> Enum.into(%{
        date: ~U[2024-08-11 01:05:00Z],
        description: "some description",
        name: "some name"
      })
      |> RFDataViewer.RFData.create_rf_data_set()

    rf_data_set
  end

  @doc """
  Generate a rf_gain.
  """
  def rf_gain_fixture(attrs \\ %{}) do
    {:ok, rf_gain} =
      attrs
      |> Enum.into(%{
        frequency: 42,
        gain: 120.5
      })
      |> RFDataViewer.RFData.create_rf_gain()

    rf_gain
  end

  @doc """
  Generate a rf_vswr.
  """
  def rf_vswr_fixture(attrs \\ %{}) do
    {:ok, rf_vswr} =
      attrs
      |> Enum.into(%{
        frequency: 42,
        vswr: 120.5
      })
      |> RFDataViewer.RFData.create_rf_vswr()

    rf_vswr
  end
end
