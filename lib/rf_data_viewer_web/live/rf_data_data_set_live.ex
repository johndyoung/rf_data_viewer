defmodule RFDataViewerWeb.RFDataDataSetLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFData
  alias RFDataViewer.Users

  def mount(
        %{"data_set_id" => ds_id} = _params,
        _session,
        %{assigns: %{current_user: user}} = socket
      ) do
    socket =
      socket
      |> allow_upload(:gain_upload, accept: ~w(.csv), max_entries: 1)
      |> allow_upload(:vswr_upload, accept: ~w(.csv), max_entries: 1)
      |> assign_data_set(ds_id)
      |> assign_measurements(:gain)
      |> assign_measurements(:vswr)
      |> assign(:delete_type, "")
      |> assign(:modal_id, "")
      |> assign_local_datetime(user)

    {:ok, socket, temporary_assigns: [gain_table: [], vswr_table: []]}
  end

  def handle_event("load_more", %{"type" => type} = _params, socket)
      when type == "gain" or type == "vswr" do
    {:noreply, assign_measurements(socket, String.to_existing_atom(type))}
  end

  def handle_event("delete", %{"type" => type}, socket)
      when type == "Gain" or type == "VSWR" do
    {:noreply,
     socket
     |> assign(:delete_type, type)
     |> push_open_modal("delete")}
  end

  def handle_event("confirm_delete", _params, %{assigns: %{delete_type: type}} = socket)
      when type == "Gain" or type == "VSWR" do
    type = String.to_existing_atom(String.downcase(type))

    {count, _} =
      case type do
        :gain -> RFData.delete_rf_gain(socket.assigns.data_set.id)
        :vswr -> RFData.delete_rf_vswr(socket.assigns.data_set.id)
      end

    socket =
      socket
      |> redirect(to: "/rf/data/data_set/#{socket.assigns.data_set.id}")
      |> put_flash(:info, "Deleted #{count} #{type} measurements.")

    {:noreply, socket}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:delete_type, "")
     |> push_close_modal("delete")}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :gain_upload, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, %{assigns: %{data_set: data_set}} = socket) do
    transform_data = fn path ->
      File.stream!(path)
      |> CSV.decode!()
      |> Stream.drop(1)
      |> Enum.map(&List.to_tuple(&1))
      |> Enum.map(fn {freq, measurement} ->
        {String.to_integer(freq), elem(Float.parse(measurement), 0)}
      end)
    end

    gain? =
      consume_uploaded_entries(socket, :gain_upload, fn %{path: path}, _entry ->
        entities =
          transform_data.(path)
          |> Enum.map(fn {freq, measurement} ->
            %{frequency: freq, gain: measurement}
          end)

        {count, _} = RFData.batch_create_rf_gain(data_set, entities)
        {:ok, count}
      end) != []

    vswr? =
      consume_uploaded_entries(socket, :vswr_upload, fn %{path: path}, _entry ->
        entities =
          transform_data.(path)
          |> Enum.map(fn {freq, measurement} ->
            %{frequency: freq, vswr: measurement}
          end)

        {count, _} = RFData.batch_create_rf_vswr(data_set, entities)
        {:ok, count}
      end) != []

    socket = if gain?, do: assign_measurements(socket, :gain), else: socket
    socket = if vswr?, do: assign_measurements(socket, :vswr), else: socket

    socket =
      socket
      |> assign_data_set(data_set.id)

    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp assign_data_set(socket, data_set_id) do
    {data_set, gain_count, vswr_count} = RFData.get_rf_data_set_with_counts!(data_set_id)

    socket
    |> assign(:data_set, data_set)
    |> assign(:gain_count, gain_count)
    |> assign(:vswr_count, vswr_count)
    |> assign_update_charts()
  end

  defp assign_update_charts(socket) do
    gain =
      socket.assigns.data_set.gain
      |> Enum.map(&%{x: &1.frequency, y: &1.gain})

    vswr =
      socket.assigns.data_set.vswr
      |> Enum.map(&%{x: &1.frequency, y: &1.vswr})

    socket
    |> push_event("rf-data-generate-chart", %{
      graph_container_id: "gainChartContainer",
      title: "#{socket.assigns.data_set.name} Gain",
      y_axis: "Gain (dBm)",
      data: gain
    })
    |> push_event("rf-data-generate-chart", %{
      graph_container_id: "vswrChartContainer",
      title: "#{socket.assigns.data_set.name} VSWR",
      y_axis: "VSWR",
      data: vswr
    })
  end

  defp assign_measurements(
         %{
           assigns: %{
             data_set: %{id: data_set_id},
             highest_gain_freq: highest_gain_freq,
             highest_vswr_freq: highest_vswr_freq
           }
         } =
           socket,
         type
       ) do
    {data_type, data, freq_type, freq} =
      case type do
        :gain ->
          {gain_table, highest_gain_freq} =
            get_measurements(:gain, data_set_id, start: highest_gain_freq, limit: 50)

          {:gain_table, gain_table, :highest_gain_freq, highest_gain_freq}

        :vswr ->
          {vswr_table, highest_vswr_freq} =
            get_measurements(:vswr, data_set_id, start: highest_vswr_freq, limit: 50)

          {:vswr_table, vswr_table, :highest_vswr_freq, highest_vswr_freq}
      end

    socket
    |> assign(data_type, data)
    |> assign(freq_type, freq)
  end

  defp assign_measurements(socket, type) do
    socket
    |> assign(:highest_gain_freq, 0)
    |> assign(:highest_vswr_freq, 0)
    |> assign_measurements(type)
  end

  defp get_measurements(:gain, data_set_id, criteria),
    do: get_measurement_data(&RFData.list_rf_gain/2, data_set_id, criteria)

  defp get_measurements(:vswr, data_set_id, criteria),
    do: get_measurement_data(&RFData.list_rf_vswr/2, data_set_id, criteria)

  defp get_measurement_data(context_getter, data_set_id, criteria) do
    data = context_getter.(data_set_id, criteria)
    highest_freq = Enum.max_by(data, & &1.frequency, fn -> %{frequency: 0} end).frequency
    {data, highest_freq}
  end

  defp assign_local_datetime(socket, user) do
    local_datetime = Users.convert_time_to_user_time(user, socket.assigns.data_set.date)
    assign(socket, :local_datetime, local_datetime)
  end
end
