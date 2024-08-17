defmodule RFDataViewerWeb.RFUnitsUnitLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFUnits.RFUnitSerialNumber
  alias RFDataViewer.RFUnits

  def mount(%{"rf_unit_id" => unit_id} = _params, _session, socket) do
    unit = RFUnits.get_rf_unit!(unit_id)
    data = RFUnits.get_rf_unit_serial_numbers_with_counts(unit.id)
    empty_sn = %RFUnitSerialNumber{}
    empty_changeset = RFUnits.change_rf_unit_serial_number(empty_sn)

    {:ok,
     socket
     |> assign(unit: unit, serial_numbers: data)
     |> assign(:check_errors, false)
     |> assign(:delete_data, [])
     |> assign_modal_id("")
     |> assign_edit_sn(empty_sn)
     |> assign_form(empty_changeset)}
  end

  def handle_event("create", _params, socket) do
    # ensure we have an empty form in case user clicked edit sometime before
    empty_sn = %RFUnitSerialNumber{}
    empty_changeset = RFUnits.change_rf_unit_serial_number(empty_sn)

    {:noreply,
     socket
     |> assign_form(empty_changeset)
     |> assign_edit_sn(empty_sn)
     |> push_open_modal("sn-form-container")}
  end

  def handle_event("edit", %{"sn_id" => id}, socket) do
    sn = RFUnits.get_rf_unit_serial_number!(id)
    sn_changeset = RFUnits.change_rf_unit_serial_number(sn)

    {:noreply,
     socket
     |> assign_form(sn_changeset)
     |> assign_edit_sn(sn)
     |> push_open_modal("sn-form-container")}
  end

  def handle_event("delete", %{"sn_id" => id}, socket) do
    sn = RFUnits.get_rf_unit_serial_number!(id)

    delete_data = [
      {"Manufacturer", socket.assigns.unit.manufacturer},
      {"Name", socket.assigns.unit.name},
      {"Serial Number", sn.serial_number}
    ]

    {:noreply,
     socket
     |> assign_edit_sn(sn)
     |> assign(:delete_data, delete_data)
     |> push_open_modal("delete-sn")}
  end

  def handle_event("confirm_delete", %{"data" => id}, socket) do
    sn_struct = RFUnits.get_rf_unit_serial_number!(String.to_integer(id))

    case RFUnits.delete_rf_unit_serial_number(sn_struct) do
      {:ok, sn} ->
        {:noreply,
         socket
         |> assign(:serial_numbers, RFUnits.get_rf_unit_serial_numbers_with_counts(sn.rf_unit_id))
         |> assign_edit_sn(%RFUnitSerialNumber{})
         |> push_close_modal("delete-sn")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset.errors

        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete Serial Number.")}
    end
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign_edit_sn(%RFUnitSerialNumber{})
     |> push_close_modal("delete-sn")}
  end

  def handle_event(
        "save",
        %{"sn" => sn_params},
        %{assigns: %{edit_sn: edit_sn, unit: unit}} = socket
      ) do
    # if edit_sn contains a serial number struct with an ID, we're updating it; otherwise, we're making a new serial number.
    response =
      case edit_sn.id do
        nil -> RFUnits.create_rf_unit_serial_number(unit, sn_params)
        id when is_integer(id) -> RFUnits.update_rf_unit_serial_number(edit_sn, sn_params)
      end

    case response do
      {:ok, sn} ->
        # entries from RFUnits.get_rf_unit_serial_numbers_with_counts/1 are of the form {sn, ts_count, ds_count, data_count}
        sn_tuple = {sn, 0, 0, 0}
        empty_sn = %RFUnitSerialNumber{}
        empty_changeset = RFUnits.change_rf_unit_serial_number(empty_sn)

        # currently adding new serial numbers to head of list... for updates, just re-query.
        socket =
          if is_nil(edit_sn.id),
            do: update(socket, :serial_numbers, fn sns -> [sn_tuple | sns] end),
            else:
              assign(
                socket,
                :serial_numbers,
                RFUnits.get_rf_unit_serial_numbers_with_counts(edit_sn.rf_unit_id)
              )

        {:noreply,
         socket
         |> assign_edit_sn(empty_sn)
         |> assign_form(empty_changeset)
         |> push_close_modal("sn-form-container")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"sn" => sn_params}, socket) do
    changeset = RFUnits.change_rf_unit_serial_number(%RFUnitSerialNumber{}, sn_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_edit_sn(socket, %RFUnitSerialNumber{} = sn), do: assign(socket, :edit_sn, sn)

  defp assign_form(socket, %Ecto.Changeset{} = changeset),
    do: RFDataViewerWeb.FormHelper.assign_form(socket, "sn", changeset)
end
