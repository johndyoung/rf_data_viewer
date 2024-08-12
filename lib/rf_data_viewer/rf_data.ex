defmodule RFDataViewer.RFData do
  @moduledoc """
  The RFData context.
  """

  import Ecto.Query, warn: false
  alias RFDataViewer.RFUnits.RFUnitSerialNumber
  alias RFDataViewer.Repo

  alias RFDataViewer.RFData.RFTestSet

  @doc """
  Returns the list of rf_test_set.

  ## Examples

      iex> list_rf_test_set()
      [%RFTestSet{}, ...]

  """
  def list_rf_test_set do
    Repo.all(RFTestSet)
  end

  @doc """
  Gets a single rf_test_set.

  Raises `Ecto.NoResultsError` if the Rf test set does not exist.

  ## Examples

      iex> get_rf_test_set!(123)
      %RFTestSet{}

      iex> get_rf_test_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_test_set!(id), do: Repo.get!(RFTestSet, id)

  @doc """
  Creates a rf_test_set.

  ## Examples

      iex> create_rf_test_set(%{field: value})
      {:ok, %RFTestSet{}}

      iex> create_rf_test_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_test_set(%RFUnitSerialNumber{} = rf_unit_serial_number, attrs \\ %{}) do
    rf_unit_serial_number
    |> Ecto.build_assoc(:rf_unit_serial_numbers)
    |> RFTestSet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_test_set.

  ## Examples

      iex> update_rf_test_set(rf_test_set, %{field: new_value})
      {:ok, %RFTestSet{}}

      iex> update_rf_test_set(rf_test_set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_test_set(%RFTestSet{} = rf_test_set, attrs) do
    rf_test_set
    |> RFTestSet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_test_set.

  ## Examples

      iex> delete_rf_test_set(rf_test_set)
      {:ok, %RFTestSet{}}

      iex> delete_rf_test_set(rf_test_set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_test_set(%RFTestSet{} = rf_test_set) do
    Repo.delete(rf_test_set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_test_set changes.

  ## Examples

      iex> change_rf_test_set(rf_test_set)
      %Ecto.Changeset{data: %RFTestSet{}}

  """
  def change_rf_test_set(%RFTestSet{} = rf_test_set, attrs \\ %{}) do
    RFTestSet.changeset(rf_test_set, attrs)
  end
end
