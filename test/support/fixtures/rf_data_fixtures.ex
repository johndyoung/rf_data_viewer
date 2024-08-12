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
end
