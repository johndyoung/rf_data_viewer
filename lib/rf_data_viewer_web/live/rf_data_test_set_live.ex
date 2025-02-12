defmodule RFDataViewerWeb.RFDataTestSetLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFData
  alias RFDataViewer.RFData.RFDataSet
  alias RFDataViewer.Users

  def mount(
        %{"test_set_id" => ts_id} = _params,
        _session,
        %{assigns: %{current_user: user}} = socket
      ) do
    {ts, ds_count, data_count} = RFDataViewer.RFData.get_rf_test_set_with_count!(ts_id)

    empty_ds = %RFDataSet{}
    empty_changeset = RFData.change_rf_data_set(empty_ds)

    {:ok,
     socket
     |> assign(
       test_set: ts,
       data_set_count: ds_count,
       data_count: data_count
     )
     |> assign_data_set_list(user, ts_id)
     |> assign(:check_errors, false)
     |> assign(:delete_data, [])
     |> assign_modal_id("")
     |> assign_local_datetime(user, Timex.now())
     |> assign_edit_ds(empty_ds)
     |> assign_form(empty_changeset)}
  end

  def handle_event("create", _params, %{assigns: %{current_user: user}} = socket) do
    # ensure we have an empty form in case user clicked edit sometime before
    empty_ds = %RFDataSet{}
    empty_changeset = RFData.change_rf_data_set(empty_ds)

    {:noreply,
     socket
     |> assign_local_datetime(user, Timex.now())
     |> assign_form(empty_changeset)
     |> assign_edit_ds(empty_ds)
     |> push_open_modal("ds-form-container")}
  end

  def handle_event("edit", %{"ds_id" => id}, %{assigns: %{current_user: user}} = socket) do
    ds = RFData.get_rf_data_set!(id)
    ds_changeset = RFData.change_rf_data_set(ds)

    {:noreply,
     socket
     |> assign_local_datetime(user, ds.date)
     |> assign_form(ds_changeset)
     |> assign_edit_ds(ds)
     |> push_open_modal("ds-form-container")}
  end

  def handle_event("delete", %{"ds_id" => id}, %{assigns: %{current_user: user}} = socket) do
    ds = RFData.get_rf_data_set!(id)

    delete_data = [
      {"Manufacturer", socket.assigns.test_set.serial_number.unit.manufacturer},
      {"Name", socket.assigns.test_set.serial_number.unit.name},
      {"Serial Number", socket.assigns.test_set.serial_number.serial_number},
      {"Test Set Name", socket.assigns.test_set.name},
      {"Test Set Location", socket.assigns.test_set.location},
      {"Test Set Date", socket.assigns.test_set.date},
      {"Data Set Name", ds.name},
      {"Data Set Date", Users.convert_time_to_user_time(user, ds.date)}
    ]

    {:noreply,
     socket
     |> assign(:delete_data, delete_data)
     |> assign_edit_ds(ds)
     |> push_open_modal("delete-ds")}
  end

  def handle_event("confirm_delete", %{"data" => id}, %{assigns: %{current_user: user}} = socket) do
    ds_struct = RFData.get_rf_data_set!(String.to_integer(id))

    case RFData.delete_rf_data_set(ds_struct) do
      {:ok, ds} ->
        {:noreply,
         socket
         |> assign_data_set_list(user, ds.rf_test_set_id)
         |> assign_edit_ds(%RFDataSet{})
         |> push_close_modal("delete-ds")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset.errors

        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete Data Set.")}
    end
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign_edit_ds(%RFDataSet{})
     |> push_close_modal("delete-ds")}
  end

  def handle_event(
        "save",
        %{"ds" => ds_params},
        %{assigns: %{edit_ds: edit_ds, test_set: ts, current_user: user}} = socket
      ) do
    date =
      Map.get(ds_params, "date")
      |> utc_datetime_from_user_input(user.timezone)

    ds_params = Map.replace(ds_params, "date", date)

    # if edit_ds contains a data set struct with an ID, we're updating it; otherwise, we're making a new data set.
    response =
      case edit_ds.id do
        nil -> RFData.create_rf_data_set(ts, ds_params)
        id when is_integer(id) -> RFData.update_rf_data_set(edit_ds, ds_params)
      end

    case response do
      {:ok, ds} ->
        # match map format of :data_sets data
        ds_data = %{
          "data" => ds,
          "gain_count" => 0,
          "vswr_count" => 0,
          "local_datetime" => Users.convert_time_to_user_time(user, ds.date)
        }

        empty_ds = %RFDataSet{}
        empty_changeset = RFData.change_rf_data_set(empty_ds)

        # currently adding new data set to head of list... for updates, just re-query.
        socket =
          if is_nil(edit_ds.id),
            do: update(socket, :data_sets, fn sets -> [ds_data | sets] end),
            else: assign_data_set_list(socket, user, ts.id)

        {:noreply,
         socket
         |> assign_edit_ds(empty_ds)
         |> assign_form(empty_changeset)
         |> push_close_modal("ds-form-container")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"ds" => ds_params}, socket) do
    changeset = RFData.change_rf_data_set(%RFDataSet{}, ds_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_data_set_list(socket, user, test_set_id) do
    data =
      RFDataViewer.RFData.get_rf_data_sets_with_counts(test_set_id, ["gain", "vswr"])
      |> Enum.map(fn %{"data" => set} = data ->
        Map.put(data, "local_datetime", Users.convert_time_to_user_time(user, set.date))
      end)

    assign(socket, :data_sets, data)
  end

  defp assign_local_datetime(socket, user, utc_datetime) do
    local_datetime = Users.convert_time_to_user_time(user, utc_datetime)
    assign(socket, :local_datetime, local_datetime)
  end

  defp assign_edit_ds(socket, %RFDataSet{} = ds), do: assign(socket, :edit_ds, ds)

  defp assign_form(socket, %Ecto.Changeset{} = changeset),
    do: RFDataViewerWeb.FormHelper.assign_form(socket, "ds", changeset)

  defp add_timezone(datetime, timezone) do
    with {:ok, time} <- datetime do
      Timex.to_datetime(time, timezone)
    end
  end

  defp utc_datetime_from_user_input(datetime, timezone) do
    datetime
    |> Timex.parse("{ISO:Extended}")
    |> add_timezone(timezone)
    |> add_timezone(:utc)
  end
end
