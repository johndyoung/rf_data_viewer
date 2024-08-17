defmodule RFDataViewerWeb.RFUnitsManageLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFUnits.RFUnit
  alias RFDataViewer.RFUnits

  def mount(_params, _session, socket) do
    rf_units = RFUnits.list_rf_units_with_counts()
    empty_unit = %RFUnit{}
    empty_changeset = RFUnits.change_rf_unit(empty_unit)

    {:ok,
     socket
     |> assign(:rf_units, rf_units)
     |> assign(:check_errors, false)
     |> assign_modal_id("")
     |> assign_edit_unit(empty_unit)
     |> assign_form(empty_changeset)}
  end

  def handle_event("create", _params, socket) do
    # ensure we have an empty form in case user clicked edit sometime before
    empty_unit = %RFUnit{}
    empty_changeset = RFUnits.change_rf_unit(empty_unit)

    {:noreply,
     socket
     |> assign_form(empty_changeset)
     |> assign_edit_unit(empty_unit)
     |> push_open_modal("unit-form-container")}
  end

  def handle_event("edit", %{"rf_unit_id" => id}, socket) do
    unit = RFUnits.get_rf_unit!(id)
    unit_changeset = RFUnits.change_rf_unit(unit)

    {:noreply,
     socket
     |> assign_form(unit_changeset)
     |> assign_edit_unit(unit)
     |> push_open_modal("unit-form-container")}
  end

  def handle_event("delete", %{"rf_unit_id" => id}, socket) do
    unit = RFUnits.get_rf_unit!(id)

    {:noreply,
     socket
     |> assign_edit_unit(unit)
     |> push_open_modal("delete-rf-unit")}
  end

  def handle_event("confirm_delete", %{"rf_unit_id" => id}, socket) do
    case RFUnits.delete_rf_unit_by_id(String.to_integer(id)) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:rf_units, RFUnits.list_rf_units_with_counts())
         |> assign_edit_unit(%RFUnit{})
         |> push_close_modal("delete-rf-unit")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset.errors
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete RF unit.")}
    end
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign_edit_unit(%RFUnit{})
     |> push_close_modal("delete-rf-unit")}
  end

  def handle_event(
        "save",
        %{"unit" => unit_params},
        %{assigns: %{edit_rf_unit: edit_unit}} = socket
      ) do
    # if edit_unit contains an RF unit struct with an ID, we're updating it; otherwise, we're making a new RF unit.
    response =
      case edit_unit.id do
        nil -> RFUnits.create_rf_unit(unit_params)
        id when is_integer(id) -> RFUnits.update_rf_unit(edit_unit, unit_params)
      end

    case response do
      {:ok, unit} ->
        # entries from RFUnits.list_rf_units_with_counts/0 are of the form {unit, sn_count, ts_count, ds_count, data_count}
        unit_tuple = {unit, 0, 0, 0, 0}
        empty_unit = %RFUnit{}
        empty_changeset = RFUnits.change_rf_unit(empty_unit)

        # currently adding new units to head of list... for updates, just re-query.
        socket =
          if is_nil(edit_unit.id),
            do: update(socket, :rf_units, fn units -> [unit_tuple | units] end),
            else: assign(socket, :rf_units, RFUnits.list_rf_units_with_counts())

        {:noreply,
         socket
         |> assign_edit_unit(empty_unit)
         |> assign_form(empty_changeset)
         |> push_close_modal("unit-form-container")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"unit" => unit_params}, socket) do
    changeset = RFUnits.change_rf_unit(%RFUnit{}, unit_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_edit_unit(socket, %RFUnit{} = unit), do: assign(socket, :edit_rf_unit, unit)

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "unit")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
