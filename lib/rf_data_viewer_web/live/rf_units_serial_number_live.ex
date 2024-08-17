defmodule RFDataViewerWeb.RFUnitsSerialNumberLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFData
  alias RFDataViewer.RFData.RFTestSet
  alias RFDataViewer.Repo

  def mount(%{"sn_id" => sn_id} = _params, _session, socket) do
    sn =
      RFDataViewer.RFUnits.get_rf_unit_serial_number!(sn_id)
      |> Repo.preload(:unit)

    test_sets = RFDataViewer.RFData.get_rf_test_sets_with_counts(sn.id)

    empty_ts = %RFTestSet{}
    empty_changeset = RFData.change_rf_test_set(empty_ts)

    {:ok,
     socket
     |> assign(%{sn: sn, test_sets: test_sets})
     |> assign(:check_errors, false)
     |> assign_modal_id("")
     |> assign_edit_ts(empty_ts)
     |> assign_form(empty_changeset)}
  end

  def handle_event("create", _params, socket) do
    # ensure we have an empty form in case user clicked edit sometime before
    empty_ts = %RFTestSet{}
    empty_changeset = RFData.change_rf_test_set(empty_ts)

    {:noreply,
     socket
     |> assign_form(empty_changeset)
     |> assign_edit_ts(empty_ts)
     |> push_open_modal("ts-form-container")}
  end

  def handle_event("edit", %{"ts_id" => id}, socket) do
    ts = RFData.get_rf_test_set!(id)
    ts_changeset = RFData.change_rf_test_set(ts)

    {:noreply,
     socket
     |> assign_form(ts_changeset)
     |> assign_edit_ts(ts)
     |> push_open_modal("ts-form-container")}
  end

  def handle_event("delete", %{"ts_id" => id}, socket) do
    ts = RFData.get_rf_test_set!(id)

    {:noreply,
     socket
     |> assign_edit_ts(ts)
     |> push_open_modal("delete-ts")}
  end

  def handle_event("confirm_delete", %{"ts_id" => id}, socket) do
    ts_struct = RFData.get_rf_test_set!(String.to_integer(id))
    case RFData.delete_rf_test_set(ts_struct) do
      {:ok, ts} ->
        {:noreply,
         socket
         |> assign(:test_sets, RFData.get_rf_test_sets_with_counts(ts.rf_unit_serial_number_id))
         |> assign_edit_ts(%RFTestSet{})
         |> push_close_modal("delete-ts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset.errors
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete Test Set.")}
    end
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign_edit_ts(%RFTestSet{})
     |> push_close_modal("delete-ts")}
  end

  def handle_event(
        "save",
        %{"ts" => ts_params},
        %{assigns: %{edit_ts: edit_ts, sn: sn}} = socket
      ) do
    # if edit_ts contains a test set struct with an ID, we're updating it; otherwise, we're making a new test set.
    response =
      case edit_ts.id do
        nil -> RFData.create_rf_test_set(sn, ts_params)
        id when is_integer(id) -> RFData.update_rf_test_set(edit_ts, ts_params)
      end

    case response do
      {:ok, ts} ->
        # entries from RFData.get_rf_test_sets_with_counts/1 are of the form {sn, ds_count, data_count}
        ts_tuple = {ts, 0, 0}
        empty_ts = %RFTestSet{}
        empty_changeset = RFData.change_rf_test_set(empty_ts)

        # currently adding new test set to head of list... for updates, just re-query.
        socket =
          if is_nil(edit_ts.id),
            do: update(socket, :test_sets, fn sets -> [ts_tuple | sets] end),
            else: assign(socket, :test_sets, RFData.get_rf_test_sets_with_counts(sn.id))

        {:noreply,
         socket
         |> assign_edit_ts(empty_ts)
         |> assign_form(empty_changeset)
         |> push_close_modal("ts-form-container")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"ts" => ts_params}, socket) do
    changeset = RFData.change_rf_test_set(%RFTestSet{}, ts_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_edit_ts(socket, %RFTestSet{} = ts), do: assign(socket, :edit_ts, ts)

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "ts")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
