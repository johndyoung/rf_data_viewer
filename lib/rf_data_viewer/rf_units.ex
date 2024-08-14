defmodule RFDataViewer.RFUnits do
  @moduledoc """
  The RFUnits context.
  """

  import Ecto.Query, warn: false
  alias RFDataViewer.RFUnits.RFUnitSerialNumber
  alias RFDataViewer.Repo

  alias RFDataViewer.RFUnits.RFUnit

  @doc """
  Returns the list of rf_units.

  ## Examples

      iex> list_rf_units()
      [%RFUnit{}, ...]

  """
  def list_rf_units do
    Repo.all(RFUnit)
  end

  @doc """
  Returns a list of all RF units in a tuple of the form {rf_unit, sn_count, data_count}

  ## Examples

      iex> list_rf_units_with_counts()
      [{%RFUnit{}, 0, 0}, ...]
  """
  def list_rf_units_with_counts do
    query =
      from u in RFUnit,
        left_join: sn in assoc(u, :serial_numbers),
        left_join: ts in assoc(sn, :test_sets),
        left_join: ds in assoc(ts, :data_sets),
        left_join: g in assoc(ds, :gain),
        left_join: v in assoc(ds, :vswr),
        group_by: u.id,
        select: {u, count(sn.id), count(g.id) + count(v.id)}

    Repo.all(query)
  end

  @doc """
  Gets a single rf_unit.

  Raises `Ecto.NoResultsError` if the Rf unit does not exist.

  ## Examples

      iex> get_rf_unit!(123)
      %RFUnit{}

      iex> get_rf_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_unit!(id), do: Repo.get!(RFUnit, id)

  @doc """
  Creates a rf_unit.

  ## Examples

      iex> create_rf_unit(%{field: value})
      {:ok, %RFUnit{}}

      iex> create_rf_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_unit(attrs \\ %{}) do
    %RFUnit{}
    |> RFUnit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_unit.

  ## Examples

      iex> update_rf_unit(rf_unit, %{field: new_value})
      {:ok, %RFUnit{}}

      iex> update_rf_unit(rf_unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_unit(%RFUnit{} = rf_unit, attrs) do
    rf_unit
    |> RFUnit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_unit.

  ## Examples

      iex> delete_rf_unit(rf_unit)
      {:ok, %RFUnit{}}

      iex> delete_rf_unit(rf_unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_unit(%RFUnit{} = rf_unit) do
    Repo.delete(rf_unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_unit changes.

  ## Examples

      iex> change_rf_unit(rf_unit)
      %Ecto.Changeset{data: %RFUnit{}}

  """
  def change_rf_unit(%RFUnit{} = rf_unit, attrs \\ %{}) do
    RFUnit.changeset(rf_unit, attrs)
  end

  alias RFDataViewer.RFUnits.RFUnitSerialNumber

  @doc """
  Returns the list of rf_unit_serial_numbers.

  ## Examples

      iex> list_rf_unit_serial_numbers()
      [%RFUnitSerialNumber{}, ...]

  """
  def list_rf_unit_serial_numbers do
    Repo.all(RFUnitSerialNumber)
  end

  @doc """
  Returns a list of all serial numbers associated with a given RF Unit in a tuple of the form {sn, test_set_count, data_count}

  ## Examples

      iex> get_rf_unit_serial_numbers_with_counts(1)
      [{%RFUnitSerialNumber{}, 0, 0}, ...]
  """
  def get_rf_unit_serial_numbers_with_counts(rf_unit_id) do
    query =
      from sn in RFUnitSerialNumber,
        left_join: ts in assoc(sn, :test_sets),
        left_join: ds in assoc(ts, :data_sets),
        left_join: g in assoc(ds, :gain),
        left_join: v in assoc(ds, :vswr),
        where: sn.rf_unit_id == ^rf_unit_id,
        group_by: sn.id,
        select: {sn, count(ts.id), count(g.id) + count(v.id)}

    Repo.all(query)
  end

  @doc """
  Gets a single rf_unit_serial_number.

  Raises `Ecto.NoResultsError` if the Rf unit serial number does not exist.

  ## Examples

      iex> get_rf_unit_serial_number!(123)
      %RFUnitSerialNumber{}

      iex> get_rf_unit_serial_number!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_unit_serial_number!(id), do: Repo.get!(RFUnitSerialNumber, id)

  @doc """
  Creates a rf_unit_serial_number.

  ## Examples

      iex> create_rf_unit_serial_number(%{field: value})
      {:ok, %RFUnitSerialNumber{}}

      iex> create_rf_unit_serial_number(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_unit_serial_number(%RFUnit{} = rf_unit, attrs \\ %{}) do
    rf_unit
    |> Ecto.build_assoc(:serial_numbers, attrs)
    |> RFUnitSerialNumber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rf_unit_serial_number.

  ## Examples

      iex> update_rf_unit_serial_number(rf_unit_serial_number, %{field: new_value})
      {:ok, %RFUnitSerialNumber{}}

      iex> update_rf_unit_serial_number(rf_unit_serial_number, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_unit_serial_number(%RFUnitSerialNumber{} = rf_unit_serial_number, attrs) do
    rf_unit_serial_number
    |> RFUnitSerialNumber.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rf_unit_serial_number.

  ## Examples

      iex> delete_rf_unit_serial_number(rf_unit_serial_number)
      {:ok, %RFUnitSerialNumber{}}

      iex> delete_rf_unit_serial_number(rf_unit_serial_number)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_unit_serial_number(%RFUnitSerialNumber{} = rf_unit_serial_number) do
    Repo.delete(rf_unit_serial_number)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_unit_serial_number changes.

  ## Examples

      iex> change_rf_unit_serial_number(rf_unit_serial_number)
      %Ecto.Changeset{data: %RFUnitSerialNumber{}}

  """
  def change_rf_unit_serial_number(%RFUnitSerialNumber{} = rf_unit_serial_number, attrs \\ %{}) do
    RFUnitSerialNumber.changeset(rf_unit_serial_number, attrs)
  end
end
