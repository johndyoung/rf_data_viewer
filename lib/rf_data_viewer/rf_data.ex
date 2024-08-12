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

  alias RFDataViewer.RFData.RFDataSet

  @doc """
  Returns the list of rf_data_set.

  ## Examples

      iex> list_rf_data_set()
      [%RFDataSet{}, ...]

  """
  def list_rf_data_set do
    Repo.all(RFDataSet)
  end

  @doc """
  Gets a single rf_data_set.

  Raises `Ecto.NoResultsError` if the Rf data set does not exist.

  ## Examples

      iex> get_rf_data_set!(123)
      %RFDataSet{}

      iex> get_rf_data_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_data_set!(id), do: Repo.get!(RFDataSet, id)

  @doc """
  Creates a rf_data_set.

  ## Examples

      iex> create_rf_data_set(%{field: value})
      {:ok, %RFDataSet{}}

      iex> create_rf_data_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_data_set(%RFTestSet{} = rf_test_set, attrs \\ %{}) do
    rf_test_set
    |> Ecto.build_assoc(:rf_test_set)
    |> RFDataSet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_data_set.

  ## Examples

      iex> update_rf_data_set(rf_data_set, %{field: new_value})
      {:ok, %RFDataSet{}}

      iex> update_rf_data_set(rf_data_set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_data_set(%RFDataSet{} = rf_data_set, attrs) do
    rf_data_set
    |> RFDataSet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_data_set.

  ## Examples

      iex> delete_rf_data_set(rf_data_set)
      {:ok, %RFDataSet{}}

      iex> delete_rf_data_set(rf_data_set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_data_set(%RFDataSet{} = rf_data_set) do
    Repo.delete(rf_data_set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_data_set changes.

  ## Examples

      iex> change_rf_data_set(rf_data_set)
      %Ecto.Changeset{data: %RFDataSet{}}

  """
  def change_rf_data_set(%RFDataSet{} = rf_data_set, attrs \\ %{}) do
    RFDataSet.changeset(rf_data_set, attrs)
  end

  alias RFDataViewer.RFData.RFGain

  @doc """
  Returns the list of rf_gain.

  ## Examples

      iex> list_rf_gain()
      [%RFGain{}, ...]

  """
  def list_rf_gain do
    Repo.all(RFGain)
  end

  @doc """
  Gets a single rf_gain.

  Raises `Ecto.NoResultsError` if the Rf gain does not exist.

  ## Examples

      iex> get_rf_gain!(123)
      %RFGain{}

      iex> get_rf_gain!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_gain!(id), do: Repo.get!(RFGain, id)

  @doc """
  Creates a rf_gain.

  ## Examples

      iex> create_rf_gain(%{field: value})
      {:ok, %RFGain{}}

      iex> create_rf_gain(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_gain(%RFDataSet{} = rf_data_set, attrs \\ %{}) do
    rf_data_set
    |> Ecto.build_assoc(:rf_data_set)
    |> RFGain.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_gain.

  ## Examples

      iex> update_rf_gain(rf_gain, %{field: new_value})
      {:ok, %RFGain{}}

      iex> update_rf_gain(rf_gain, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_gain(%RFGain{} = rf_gain, attrs) do
    rf_gain
    |> RFGain.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_gain.

  ## Examples

      iex> delete_rf_gain(rf_gain)
      {:ok, %RFGain{}}

      iex> delete_rf_gain(rf_gain)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_gain(%RFGain{} = rf_gain) do
    Repo.delete(rf_gain)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_gain changes.

  ## Examples

      iex> change_rf_gain(rf_gain)
      %Ecto.Changeset{data: %RFGain{}}

  """
  def change_rf_gain(%RFGain{} = rf_gain, attrs \\ %{}) do
    RFGain.changeset(rf_gain, attrs)
  end

  alias RFDataViewer.RFData.RFVswr

  @doc """
  Returns the list of rf_vswr.

  ## Examples

      iex> list_rf_vswr()
      [%RFVswr{}, ...]

  """
  def list_rf_vswr do
    Repo.all(RFVswr)
  end

  @doc """
  Gets a single rf_vswr.

  Raises `Ecto.NoResultsError` if the Rf vswr does not exist.

  ## Examples

      iex> get_rf_vswr!(123)
      %RFVswr{}

      iex> get_rf_vswr!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_vswr!(id), do: Repo.get!(RFVswr, id)

  @doc """
  Creates a rf_vswr.

  ## Examples

      iex> create_rf_vswr(%{field: value})
      {:ok, %RFVswr{}}

      iex> create_rf_vswr(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_vswr(%RFDataSet{} = rf_data_set, attrs \\ %{}) do
    rf_data_set
    |> Ecto.build_assoc(:rf_data_set)
    |> RFVswr.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_vswr.

  ## Examples

      iex> update_rf_vswr(rf_vswr, %{field: new_value})
      {:ok, %RFVswr{}}

      iex> update_rf_vswr(rf_vswr, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_vswr(%RFVswr{} = rf_vswr, attrs) do
    rf_vswr
    |> RFVswr.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_vswr.

  ## Examples

      iex> delete_rf_vswr(rf_vswr)
      {:ok, %RFVswr{}}

      iex> delete_rf_vswr(rf_vswr)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_vswr(%RFVswr{} = rf_vswr) do
    Repo.delete(rf_vswr)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_vswr changes.

  ## Examples

      iex> change_rf_vswr(rf_vswr)
      %Ecto.Changeset{data: %RFVswr{}}

  """
  def change_rf_vswr(%RFVswr{} = rf_vswr, attrs \\ %{}) do
    RFVswr.changeset(rf_vswr, attrs)
  end
end
