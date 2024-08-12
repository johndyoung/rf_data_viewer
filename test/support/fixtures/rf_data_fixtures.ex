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
end
