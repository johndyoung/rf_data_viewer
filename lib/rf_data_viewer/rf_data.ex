defmodule RFDataViewer.RFData do
  @moduledoc """
  The RFData context.
  """

  import Ecto.Query, warn: false
  alias RFDataViewer.Repo
  alias RFDataViewer.RFUnits.RFUnitSerialNumber
  alias RFDataViewer.RFData.RFTestSet
  alias RFDataViewer.RFData.RFDataSet
  alias RFDataViewer.RFData.RFMeasurement
  alias RFDataViewer.RFData.RFVswr

  @doc """
  Returns the list of rf_test_set.

  ## Examples

      iex> list_rf_test_set()
      [%RFTestSet{}, ...]

  """
  def list_rf_test_sets do
    Repo.all(RFTestSet)
  end

  @doc """
  Returns a list of all test sets associated with a given RF Unit Serial number in a tuple of the form {test_set, data_set_count, data_count}

  ## Examples

      iex> get_test_sets_with_counts(1)
      [{%RFTestSet{}, 0, 0}, ...]
  """
  def get_rf_test_sets_with_counts(serial_number_id) do
    data_set_subquery =
      from d in RFDataSet,
        group_by: d.rf_test_set_id,
        select: %{id: d.rf_test_set_id, count: count()}

    gain_subquery =
      from m in RFMeasurement,
        join: d in assoc(m, :data_set),
        group_by: d.rf_test_set_id,
        select: %{id: d.rf_test_set_id, count: count()}

    vswr_subquery =
      from v in RFVswr,
        join: d in assoc(v, :data_set),
        group_by: d.rf_test_set_id,
        select: %{id: d.rf_test_set_id, count: count()}

    query =
      from t in RFTestSet,
        left_join: d in subquery(data_set_subquery),
        on: d.id == t.id,
        left_join: g in subquery(gain_subquery),
        on: g.id == t.id,
        left_join: v in subquery(vswr_subquery),
        on: v.id == t.id,
        where: t.rf_unit_serial_number_id == ^serial_number_id,
        order_by: t.name,
        preload: [serial_number: :unit],
        select: {t, coalesce(d.count, 0), coalesce(g.count + v.count, 0)}

    Repo.all(query)
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
  Returns a list of all test sets associated with a given RF Unit Serial number in a tuple of the form {test_set, data_set_count, data_count}

  ## Examples

      iex> get_test_sets_with_counts(1)
      [{%RFTestSet{}, 0, 0}, ...]
  """
  def get_rf_test_set_with_count!(test_set_id) do
    data_set_subquery =
      from d in RFDataSet,
        join: t in assoc(d, :test_set),
        group_by: t.id,
        select: %{id: t.id, count: count()}

    gain_subquery =
      from m in RFMeasurement,
        join: d in assoc(m, :data_set),
        group_by: d.rf_test_set_id,
        select: %{id: d.rf_test_set_id, count: count()}

    vswr_subquery =
      from v in RFVswr,
        join: d in assoc(v, :data_set),
        group_by: d.rf_test_set_id,
        select: %{id: d.rf_test_set_id, count: count()}

    query =
      from t in RFTestSet,
        left_join: d in subquery(data_set_subquery),
        on: d.id == t.id,
        left_join: g in subquery(gain_subquery),
        on: g.id == t.id,
        left_join: v in subquery(vswr_subquery),
        on: v.id == t.id,
        where: t.id == ^test_set_id,
        order_by: t.name,
        preload: [serial_number: :unit],
        select: {t, coalesce(d.count, 0), coalesce(g.count + v.count, 0)}

    Repo.one!(query)
  end

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
    |> Ecto.build_assoc(:test_sets, attrs)
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
  def list_rf_data_sets do
    Repo.all(RFDataSet)
  end

  @doc """
  Returns the list of rf_data_sets with counts in form of tuple {data_set, gain_count, vswr_count}.

  ## Examples

      iex> get_rf_data_sets_with_counts()
      [{%RFDataSet{}, 0, 0}, ...]

  """
  def get_rf_data_sets_with_counts(test_set_id) do
    gain_subquery =
      from m in RFMeasurement,
        join: d in assoc(m, :data_set),
        group_by: d.id,
        select: %{id: d.id, count: count()}

    vswr_subquery =
      from v in RFVswr,
        join: d in assoc(v, :data_set),
        group_by: d.id,
        select: %{id: d.id, count: count()}

    query =
      from d in RFDataSet,
        left_join: g in subquery(gain_subquery),
        on: g.id == d.id,
        left_join: v in subquery(vswr_subquery),
        on: v.id == d.id,
        where: d.rf_test_set_id == ^test_set_id,
        select: {d, coalesce(g.count, 0), coalesce(v.count, 0)}

    Repo.all(query)
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
  Gets a single rf_data_set along with gain and VSWR data counts.

  Raises `Ecto.NoResultsError` if the Rf data set does not exist.

  ## Examples

      iex> get_rf_data_set_with_counts!(123)
      {%RFDataSet{}, 0, 0}

      iex> get_rf_data_set_with_counts!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_data_set_with_counts!(id) do
    gain_subquery =
      from m in RFMeasurement,
        join: d in assoc(m, :data_set),
        group_by: d.id,
        select: %{id: d.id, count: count()}

    vswr_subquery =
      from v in RFVswr,
        join: d in assoc(v, :data_set),
        group_by: d.id,
        select: %{id: d.id, count: count()}

    measurement_order = from m in RFMeasurement, where: m.type == "gain", order_by: m.frequency
    vswr_order = from v in RFVswr, order_by: v.frequency

    query =
      from d in RFDataSet,
        left_join: g in subquery(gain_subquery),
        on: g.id == d.id,
        left_join: v in subquery(vswr_subquery),
        on: v.id == d.id,
        preload: [
          measurements: ^measurement_order,
          vswr: ^vswr_order,
          test_set: [serial_number: :unit]
        ],
        where: d.id == ^id,
        select: {d, coalesce(g.count, 0), coalesce(v.count, 0)}

    Repo.one(query)
  end

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
    |> Ecto.build_assoc(:data_sets, attrs)
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

  alias RFDataViewer.RFData.RFMeasurement

  defp compose_list_measurements(query, criteria) do
    Enum.reduce(criteria, query, fn
      {:type, type}, query when is_list(type) ->
        from q in query, where: q.type in ^type

      {:type, type}, query when not is_nil(type) ->
        from q in query, where: q.type == ^type

      {:end, end_freq}, query when not is_nil(end_freq) and is_integer(end_freq) ->
        from q in query, where: q.frequency <= ^end_freq

      {:start, start_freq}, query when not is_nil(start_freq) and is_integer(start_freq) ->
        from q in query, where: q.frequency >= ^start_freq

      {:limit, limit}, query when not is_nil(limit) and is_integer(limit) ->
        from q in query, limit: ^limit

      _, query ->
        query
    end)
  end

  @doc """
  Returns the list of rf_measurements.

  ## Examples

      iex> list_rf_measurements()
      [%RFMeasurement{}, ...]

  """
  def list_rf_measurements do
    Repo.all(RFMeasurement)
  end

  def list_rf_measurements(data_set_id) when is_integer(data_set_id) do
    from(m in RFMeasurement, where: m.rf_data_set_id == ^data_set_id, order_by: m.frequency)
    |> Repo.all()
  end

  def list_rf_measurements(data_set_id, criteria)
      when is_integer(data_set_id) and is_list(criteria) do
    from(m in RFMeasurement, where: m.rf_data_set_id == ^data_set_id, order_by: m.frequency)
    |> compose_list_measurements(criteria)
    |> Repo.all()
  end

  @doc """
  Gets a single rf_measurements.

  Raises `Ecto.NoResultsError` if the RF measurement does not exist.

  ## Examples

      iex> get_rf_measurement!(123)
      %RFMeasurement{}

      iex> get_rf_measurement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rf_measurement!(id), do: Repo.get!(RFMeasurement, id)

  @doc """
  Creates a rf_measurements.

  ## Examples

      iex> create_rf_measurement(%{field: value})
      {:ok, %RFMeasurement{}}

      iex> create_rf_measurement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rf_measurement(%RFDataSet{} = rf_data_set, %{} = attrs \\ %{}) do
    rf_data_set
    |> Ecto.build_assoc(:measurements, attrs)
    |> RFMeasurement.changeset(attrs)
    |> Repo.insert()
  end

  def batch_create_rf_measurement(%RFDataSet{} = rf_data_set, entries \\ []) do
    changesets =
      entries
      |> Enum.map(fn attrs ->
        rf_data_set
        |> Ecto.build_assoc(:measurements, attrs)
        |> RFMeasurement.changeset(attrs)
      end)

    valid? = not Enum.any?(changesets, &(not &1.valid?))

    if valid? do
      date = DateTime.truncate(DateTime.utc_now(), :second)

      Repo.insert_all(
        RFMeasurement,
        changesets
        |> Enum.map(
          &%{
            type: &1.data.type,
            frequency: &1.data.frequency,
            value: &1.data.value,
            rf_data_set_id: &1.data.rf_data_set_id,
            inserted_at: date,
            updated_at: date
          }
        )
      )
    else
      {0, Enum.filter(changesets, &(not &1.valid?))}
    end
  end

  @doc """
  Updates a rf_measurement.

  ## Examples

      iex> update_rf_measurement(rf_measurement, %{field: new_value})
      {:ok, %RFMeasurement{}}

      iex> update_rf_measurement(rf_measurement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rf_measurement(%RFMeasurement{} = rf_measurement, attrs) do
    rf_measurement
    |> RFMeasurement.changeset(attrs)
    |> Repo.update()
  end

  def delete_rf_measurements(data_set_id, type \\ nil) when is_integer(data_set_id) do
    from(m in RFMeasurement, where: m.rf_data_set_id == ^data_set_id)
    |> case do
      query when not is_nil(type) -> from q in query, where: q.type == ^type
      query -> query
    end
    |> Repo.delete_all()
  end

  @doc """
  Deletes a rf_measurement.

  ## Examples

      iex> delete_rf_measurement(rf_measurement)
      {:ok, %RFMeasurement{}}

      iex> delete_rf_measurement(rf_measurement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rf_measurement(%RFMeasurement{} = rf_measurement) do
    Repo.delete(rf_measurement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rf_measurement changes.

  ## Examples

      iex> change_rf_measurement(rf_measurement)
      %Ecto.Changeset{data: %RFMeasurement{}}

  """
  def change_rf_measurement(%RFMeasurement{} = rf_measurement, attrs \\ %{}) do
    RFMeasurement.changeset(rf_measurement, attrs)
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

  def list_rf_vswr(data_set_id) when is_integer(data_set_id) do
    from(v in RFVswr, where: v.rf_data_set_id == ^data_set_id, order_by: v.frequency)
    |> Repo.all()
  end

  def list_rf_vswr(data_set_id, criteria) when is_integer(data_set_id) and is_list(criteria) do
    from(v in RFVswr, where: v.rf_data_set_id == ^data_set_id, order_by: v.frequency)
    |> compose_list_measurements(criteria)
    |> Repo.all()
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
    |> Ecto.build_assoc(:vswr, attrs)
    |> RFVswr.changeset(attrs)
    |> Repo.insert()
  end

  def batch_create_rf_vswr(%RFDataSet{} = rf_data_set, entries \\ []) do
    changesets =
      entries
      |> Enum.map(fn attrs ->
        rf_data_set
        |> Ecto.build_assoc(:vswr, attrs)
        |> RFVswr.changeset(attrs)
      end)

    valid? = not Enum.any?(changesets, &(not &1.valid?))

    if valid? do
      date = DateTime.truncate(DateTime.utc_now(), :second)

      Repo.insert_all(
        RFVswr,
        changesets
        |> Enum.map(
          &%{
            frequency: &1.data.frequency,
            vswr: &1.data.vswr,
            rf_data_set_id: &1.data.rf_data_set_id,
            inserted_at: date,
            updated_at: date
          }
        )
      )
    else
      {0, Enum.filter(changesets, &(not &1.valid?))}
    end
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

  def delete_rf_vswr(data_set_id) when is_integer(data_set_id) do
    from(v in RFVswr, where: v.rf_data_set_id == ^data_set_id)
    |> Repo.delete_all()
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
