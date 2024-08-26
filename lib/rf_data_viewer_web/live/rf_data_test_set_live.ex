defmodule RFDataViewerWeb.RFDataTestSetLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.Repo
  alias RFDataViewer.RFData
  alias RFDataViewer.RFData.RFDataSet
  alias RFDataViewer.Users

  @manifest_file_name "manifest.csv"

  def mount(
        %{"test_set_id" => ts_id} = _params,
        _session,
        %{assigns: %{current_user: user}} = socket
      ) do
    {ts, ds_count, data_count} = RFDataViewer.RFData.get_rf_test_set_with_count!(ts_id)

    empty_ds = %RFDataSet{}
    empty_changeset = RFData.change_rf_data_set(empty_ds)

    socket =
      socket
      |> assign_test_set_metadata(ts, ds_count, data_count)
      |> assign_data_set_list(user, ts_id)
      |> init_upload()
      |> assign(:check_errors, false)
      |> assign(:delete_data, [])
      |> assign_modal_id("")
      |> assign_local_datetime(user, Timex.now())
      |> assign_edit_ds(empty_ds)
      |> assign_form(empty_changeset)

    {:ok, socket}
  end

  defp assign_test_set_metadata(socket, test_set, data_set_count, data_count),
    do:
      assign(socket,
        test_set: test_set,
        data_set_count: data_set_count,
        data_count: data_count
      )

  defp init_upload(socket) do
    socket
    |> assign(
      manifest_file_name: @manifest_file_name,
      files: [],
      upload_count: nil,
      upload_errors: 0,
      uploaded: 0,
      upload_progress: 0,
      manifest_file: nil,
      status: nil,
      files_to_process: 0,
      process_progress: 0,
      processing: false,
      temp_dir: nil
    )
    |> allow_upload(:dir,
      accept: ~w(.csv),
      # 500 files plus a manifest file. users with junky directories can just clean their stuff up!
      max_entries: 501,
      # 1 MB max file size
      max_file_size: 1_000_000,
      auto_upload: true,
      progress: &handle_progress/3
    )
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
        {ts, ds_count, data_count} =
          RFDataViewer.RFData.get_rf_test_set_with_count!(ds.rf_test_set_id)

        {:noreply,
         socket
         |> assign_test_set_metadata(ts, ds_count, data_count)
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
      {:ok, _} ->
        empty_ds = %RFDataSet{}
        empty_changeset = RFData.change_rf_data_set(empty_ds)

        {ts, ds_count, data_count} = RFDataViewer.RFData.get_rf_test_set_with_count!(ts.id)

        socket =
          socket
          |> assign_test_set_metadata(ts, ds_count, data_count)
          |> assign_data_set_list(user, ts.id)
          |> assign_edit_ds(empty_ds)
          |> assign_form(empty_changeset)
          |> push_close_modal("ds-form-container")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"ds" => ds_params}, socket) do
    changeset = RFData.change_rf_data_set(%RFDataSet{}, ds_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  # def handle_event("cancel_upload", %{"ref" => ref}, socket) do
  #   {:noreply, cancel_upload(socket, :dir, ref)}
  # end

  def handle_event("files-selected", _, socket) do
    # remove subdirectories and invalid uploads
    socket =
      Enum.reduce(socket.assigns.uploads.dir.entries, socket, fn entry, socket ->
        path_components = Path.split(entry.client_relative_path)
        # relative client path always includes the directory in which the file resides,
        # so we expect exactly two components for the top-level upload directory.
        if length(path_components) == 2 && entry.valid?,
          do: socket,
          else: cancel_upload(socket, :dir, entry.ref)
      end)

    socket =
      socket
      |> assign(:upload_count, length(socket.assigns.uploads.dir.entries))
      |> assign(:upload_errors, length(socket.assigns.uploads.dir.errors))

    socket =
      if socket.assigns.upload_count > 0,
        do: assign(socket, :status, "Uploading files..."),
        else: socket

    {:noreply, socket}
  end

  def handle_progress(:dir, entry, socket) do
    valid_uploads = socket.assigns.upload_count - socket.assigns.upload_errors

    socket =
      if entry.done? do
        upload_progress =
          (socket.assigns.uploaded / valid_uploads * 100)
          |> Float.round(2)

        socket =
          socket
          |> assign(:uploaded, socket.assigns.uploaded + 1)
          |> assign(:upload_progress, upload_progress)
          |> assign(:files, socket.assigns.files ++ [entry.client_name])

        case entry.client_name do
          @manifest_file_name when not is_nil(socket.assigns.manifest_file) ->
            # detected multiple manifest files
            assign(socket, :manifest_file, :multiple)

          @manifest_file_name ->
            # found manifest file!
            assign(socket, :manifest_file, entry)

          _ ->
            socket.assigns.uploads.dir.entries
            socket
        end
      else
        socket
      end

    socket =
      case socket.assigns.uploaded do
        ^valid_uploads when is_nil(socket.assigns.manifest_file) ->
          # no manifest file found
          socket
          |> cancel_uploads()
          |> assign_redirect_self()
          |> put_flash(:error, "No manifest file found. See Upload Requirements.")

        ^valid_uploads when socket.assigns.manifest_file == :multiple ->
          # detected multiple manifest files
          socket
          |> cancel_uploads()
          |> assign_redirect_self()
          |> put_flash(:error, "Multiple manifest files detected.")

        ^valid_uploads ->
          # valid so far, start processing files
          process_uploads(socket)

        _ ->
          # still uploading files
          socket
      end

    {:noreply, socket}
  end

  defp cancel_uploads(socket) do
    Enum.reduce(socket.assigns.uploads.dir.entries, socket, fn file, socket ->
      cancel_upload(socket, :dir, file.ref)
    end)
  end

  defp process_uploads(socket) do
    # copy all data to temp directory  and then spawn process to... process the data.
    upload_dir = Application.app_dir(:rf_data_viewer, "priv/static/uploads")

    if not File.exists?(upload_dir), do: File.mkdir!(upload_dir)

    dest_dir = Path.join(upload_dir, UUID.uuid1())

    File.mkdir!(dest_dir)

    uploaded_files =
      consume_uploaded_entries(socket, :dir, fn %{path: path}, entry ->
        dest = Path.join(dest_dir, entry.client_name)
        File.cp!(path, dest)
        {:ok, dest}
      end)

    # transform the manifest file into usable data
    manifest_data =
      read_csv_file(Path.join(dest_dir, @manifest_file_name))
      |> Enum.map(
        &extract_manifest_errors(socket.assigns.current_user.timezone, uploaded_files, &1)
      )

    # validate the manifest file
    {result, data} =
      if Enum.any?(manifest_data, fn tuple -> elem(tuple, 0) == :error end),
        do: {:error, manifest_data},
        else: {:ok, Enum.map(manifest_data, fn {_, row, _} -> row end)}

    if result == :ok do
      # manifest file looks good, process the other files
      valid_uploads = socket.assigns.upload_count - socket.assigns.upload_errors
      test_set_id = socket.assigns.test_set.id

      case length(uploaded_files) do
        ^valid_uploads ->
          # manifest file is good and all valid uploads successful
          live_view_pid = self()

          files_to_process = length(manifest_data) * 2

          socket
          |> assign(:status, "Processing files...")
          |> assign(:files_to_process, files_to_process)
          |> assign(:process_progress, 0)
          |> assign(:upload_progress, 0)
          |> assign(:processing, true)
          |> assign(:temp_dir, dest_dir)
          |> start_async(:processing_files, fn ->
            process_files!(live_view_pid, test_set_id, data, dest_dir)
          end)

        _ ->
          # some expected valid uploads failed
          File.rm_rf!(dest_dir)

          socket
          |> put_flash(:error, "Failed upload.")
          |> assign_redirect_self()
      end
    else
      # bad manifest file
      File.rm_rf!(dest_dir)

      socket
      |> put_flash(:error, build_manifest_error_messages(data))
      |> assign_redirect_self()
    end
  end

  defp process_files!(live_view_pid, test_set_id, manifest_data, dir) do
    Enum.each(manifest_data, &build_queries(&1, live_view_pid, test_set_id, dir))
    :ok
  end

  defp build_queries(row, live_view_pid, test_set_id, dir) do
    data = %{
      rf_test_set_id: test_set_id,
      name: row.test_name,
      description: row.test_desc,
      date: row.test_local_date
    }

    changeset = RFData.change_rf_data_set(%RFDataSet{}, data)

    multi = Ecto.Multi.new()

    multi =
      Ecto.Multi.insert(multi, :rf_data_set, changeset)
      |> Ecto.Multi.merge(fn %{rf_data_set: parent} ->
        [{"gain", row.gain_file}, {"vswr", row.vswr_file}]
        |> Enum.reduce(multi, &build_measurement_queries(&1, &2, live_view_pid, dir, parent))
      end)

    send(live_view_pid, {:file_processed, 2})

    Repo.transaction(multi)
  end

  def build_measurement_queries({type, file}, multi, _live_view_pid, dir, parent) do
    file_path = Path.join(dir, file)

    multi =
      if File.exists?(file_path) do
        measurements =
          read_csv_file(file_path)
          |> Enum.reduce([], fn {freq, measurement}, list ->
            measurement = %{
              type: type,
              frequency: String.to_integer(freq),
              value: elem(Float.parse(measurement), 0),
              rf_data_set_id: parent.id,
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            }

            [measurement | list]
          end)

        Ecto.Multi.insert_all(
          multi,
          {:rf_measurement, type, file},
          "rf_measurements",
          measurements
        )
      else
        multi
      end

    # can't send from inside an Ecto.Multi.merge callback...
    # send(live_view_pid, :file_processed)

    multi
  end

  def handle_info({:file_processed, processed}, socket) do
    files_processed =
      socket.assigns.process_progress + processed

    progress =
      (files_processed / socket.assigns.files_to_process * 100)
      |> Float.round(2)

    socket =
      socket
      |> assign(:process_progress, files_processed)
      |> assign(:upload_progress, progress)

    {:noreply, socket}
  end

  def handle_async(:processing_files, {:ok, _}, socket) do
    File.rm_rf!(socket.assigns.temp_dir)

    {ts, ds_count, data_count} =
      RFDataViewer.RFData.get_rf_test_set_with_count!(socket.assigns.test_set.id)

    socket =
      socket
      |> assign_test_set_metadata(ts, ds_count, data_count)
      |> assign_data_set_list(socket.assigns.current_user, ts.id)
      |> assign(:temp_dir, nil)
      |> assign(:processing, false)
      |> init_upload()
      |> assign_data_set_list(socket.assigns.current_user, socket.assigns.test_set.id)
      |> put_flash(:info, "Processed uploaded data!")

    {:noreply, socket}
  end

  def handle_async(:processing_files, {:exit, {reason, _}}, socket) do
    File.rm_rf!(socket.assigns.temp_dir)

    socket =
      socket
      |> assign(:temp_dir, nil)
      |> assign(:processing, :error)
      |> init_upload()
      |> put_flash(:error, "Failed to process uploaded data: #{reason.message}")

    {:noreply, socket}
  end

  defp read_csv_file(path, header_row? \\ true) do
    drop_rows = if header_row?, do: 1, else: 0

    File.stream!(path)
    |> CSV.decode!()
    |> Stream.drop(drop_rows)
    |> Enum.map(&List.to_tuple(&1))
  end

  defp extract_manifest_errors(
         timezone,
         uploaded_files,
         {test_name, test_desc, test_date, gain_file, vswr_file}
       ) do
    test_name = safe_to_string(html_escape(test_name))
    test_desc = safe_to_string(html_escape(test_desc))

    test_date =
      safe_to_string(html_escape(test_date))
      |> Timex.parse("{RFC3339}")
      |> add_timezone(timezone)
      |> add_timezone(:utc)

    gain_file = safe_to_string(html_escape(gain_file))
    vswr_file = safe_to_string(html_escape(vswr_file))

    row_data = %{
      test_name: test_name,
      test_desc: test_desc,
      test_local_date: test_date,
      gain_file: gain_file,
      vswr_file: vswr_file
    }

    errors =
      %{
        "Test Name" => String.length(test_name) > 0,
        "Test Description" => String.length(test_desc) > 0,
        "Test Date" => not is_tuple(test_date),
        "Gain File Name" =>
          length(
            Enum.filter(
              uploaded_files,
              &(Path.basename(&1) == gain_file)
            )
          ) == 1,
        "VSWR File Name" =>
          length(
            Enum.filter(
              uploaded_files,
              &(Path.basename(&1) == vswr_file)
            )
          ) == 1
      }
      |> Enum.filter(fn {_, result} -> result != true end)
      |> Enum.map(fn {key, _} -> key end)
      |> Enum.to_list()

    if length(errors) == 0,
      do: {:ok, row_data, []},
      else: {:error, row_data, errors}
  end

  defp build_manifest_error_messages(manifest_data) do
    Enum.reduce(manifest_data, [], fn {row_result, %{test_name: row_test_name}, row_errors},
                                      error_messages ->
      case row_result do
        :ok ->
          error_messages

        _ ->
          li_begin = "<li class=\"pl-5 text-sm\">"

          row_error_message =
            row_errors
            |> Enum.reverse()
            |> Enum.join("</li>#{li_begin}")
            |> (&"<div class=\"text-sm\">Error with entry #{row_test_name}<ul>#{li_begin}#{&1}</li></ul></div>").()

          [
            row_error_message
            | error_messages
          ]
      end
    end)
    |> Enum.reverse()
    |> Enum.join()
    |> (&"<span class=\"font-semibold\">Manifest file errors:</span>#{&1}").()
    |> raw()
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

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

  defp assign_redirect_self(socket),
    do: redirect(socket, to: "/rf/data/test_set/#{socket.assigns.test_set.id}")

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
