defmodule RFDataViewer.RFDataTest do
  use RFDataViewer.DataCase
  alias RFDataViewer.RFData
  alias RFDataViewer.RFUnitsFixtures

  describe "rf_test_set" do
    alias RFDataViewer.RFData.RFTestSet

    import RFDataViewer.RFDataFixtures

    @invalid_attrs %{name: nil, date: nil, description: nil, location: nil}

    test "list_rf_test_set/0 returns all rf_test_set" do
      rf_test_set = rf_test_set_fixture()
      assert RFData.list_rf_test_sets() == [rf_test_set]
    end

    test "get_rf_test_set!/1 returns the rf_test_set with given id" do
      rf_test_set = rf_test_set_fixture()
      assert RFData.get_rf_test_set!(rf_test_set.id) == rf_test_set
    end

    test "create_rf_test_set/1 with valid data creates a rf_test_set" do
      rf_sn = RFDataViewer.RFUnitsFixtures.rf_unit_serial_number_fixture()

      valid_attrs = %{
        name: "some name",
        date: ~D[2024-08-11],
        description: "some description",
        location: "some location"
      }

      assert {:ok, %RFTestSet{} = rf_test_set} = RFData.create_rf_test_set(rf_sn, valid_attrs)
      assert rf_test_set.name == "some name"
      assert rf_test_set.date == ~D[2024-08-11]
      assert rf_test_set.description == "some description"
      assert rf_test_set.location == "some location"
    end

    test "create_rf_test_set/1 with invalid data returns error changeset" do
      rf_sn = RFDataViewer.RFUnitsFixtures.rf_unit_serial_number_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.create_rf_test_set(rf_sn, @invalid_attrs)
    end

    test "create_rf_test_set/1 name, location, date, and rf_unit_serial_number_id unique constraint" do
      sn = RFUnitsFixtures.rf_unit_serial_number_fixture()

      valid = %{
        name: "name",
        date: Date.utc_today(),
        description: "desc",
        location: "location"
      }

      assert {:ok, %RFTestSet{}} =
               RFData.create_rf_test_set(sn, valid)

      diff_name = Map.replace(valid, :name, "#{valid.name} diff")

      assert {:ok, %RFTestSet{}} =
               RFData.create_rf_test_set(sn, diff_name)

      diff_location = Map.replace(valid, :location, "#{valid.location} diff")

      assert {:ok, %RFTestSet{}} =
               RFData.create_rf_test_set(sn, diff_location)

      diff_date = Map.replace(valid, :date, Date.add(valid.date, 1))

      assert {:ok, %RFTestSet{}} =
               RFData.create_rf_test_set(sn, diff_date)

      assert {:error, %Ecto.Changeset{}} =
               RFData.create_rf_test_set(sn, valid)

      {:ok, unit} =
        RFDataViewer.RFUnits.create_rf_unit(%{
          name: "random",
          description: "random",
          manufacturer: "random"
        })

      {:ok, diff_sn} =
        RFDataViewer.RFUnits.create_rf_unit_serial_number(unit, %{
          serial_number: "#{sn.serial_number} diff"
        })

      assert {:ok, %RFTestSet{}} =
               RFData.create_rf_test_set(diff_sn, valid)
    end

    test "update_rf_test_set/2 with valid data updates the rf_test_set" do
      rf_test_set = rf_test_set_fixture()

      update_attrs = %{
        name: "some updated name",
        date: ~D[2024-08-12],
        description: "some updated description",
        location: "some updated location"
      }

      assert {:ok, %RFTestSet{} = rf_test_set} =
               RFData.update_rf_test_set(rf_test_set, update_attrs)

      assert rf_test_set.name == "some updated name"
      assert rf_test_set.date == ~D[2024-08-12]
      assert rf_test_set.description == "some updated description"
      assert rf_test_set.location == "some updated location"
    end

    test "update_rf_test_set/2 with invalid data returns error changeset" do
      rf_test_set = rf_test_set_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.update_rf_test_set(rf_test_set, @invalid_attrs)
      assert rf_test_set == RFData.get_rf_test_set!(rf_test_set.id)
    end

    test "delete_rf_test_set/1 deletes the rf_test_set" do
      rf_test_set = rf_test_set_fixture()
      assert {:ok, %RFTestSet{}} = RFData.delete_rf_test_set(rf_test_set)
      assert_raise Ecto.NoResultsError, fn -> RFData.get_rf_test_set!(rf_test_set.id) end
    end

    test "change_rf_test_set/1 returns a rf_test_set changeset" do
      rf_test_set = rf_test_set_fixture()
      assert %Ecto.Changeset{} = RFData.change_rf_test_set(rf_test_set)
    end
  end

  describe "rf_data_set" do
    alias RFDataViewer.RFData.RFDataSet

    import RFDataViewer.RFDataFixtures

    @invalid_attrs %{name: nil, date: nil, description: nil}

    test "list_rf_data_set/0 returns all rf_data_set" do
      rf_data_set = rf_data_set_fixture()
      assert RFData.list_rf_data_sets() == [rf_data_set]
    end

    test "get_rf_data_set!/1 returns the rf_data_set with given id" do
      rf_data_set = rf_data_set_fixture()
      assert RFData.get_rf_data_set!(rf_data_set.id) == rf_data_set
    end

    test "create_rf_data_set/1 with valid data creates a rf_data_set" do
      rf_test_set = RFDataViewer.RFDataFixtures.rf_test_set_fixture()

      valid_attrs = %{
        name: "some name",
        date: ~U[2024-08-11 01:05:00Z],
        description: "some description"
      }

      assert {:ok, %RFDataSet{} = rf_data_set} =
               RFData.create_rf_data_set(rf_test_set, valid_attrs)

      assert rf_data_set.name == "some name"
      assert rf_data_set.date == ~U[2024-08-11 01:05:00Z]
      assert rf_data_set.description == "some description"
    end

    test "create_rf_data_set/1 with invalid data returns error changeset" do
      rf_test_set = RFDataViewer.RFDataFixtures.rf_test_set_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.create_rf_data_set(rf_test_set, @invalid_attrs)
    end

    test "update_rf_data_set/2 with valid data updates the rf_data_set" do
      rf_data_set = rf_data_set_fixture()

      update_attrs = %{
        name: "some updated name",
        date: ~U[2024-08-12 01:05:00Z],
        description: "some updated description"
      }

      assert {:ok, %RFDataSet{} = rf_data_set} =
               RFData.update_rf_data_set(rf_data_set, update_attrs)

      assert rf_data_set.name == "some updated name"
      assert rf_data_set.date == ~U[2024-08-12 01:05:00Z]
      assert rf_data_set.description == "some updated description"
    end

    test "update_rf_data_set/2 with invalid data returns error changeset" do
      rf_data_set = rf_data_set_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.update_rf_data_set(rf_data_set, @invalid_attrs)
      assert rf_data_set == RFData.get_rf_data_set!(rf_data_set.id)
    end

    test "delete_rf_data_set/1 deletes the rf_data_set" do
      rf_data_set = rf_data_set_fixture()
      assert {:ok, %RFDataSet{}} = RFData.delete_rf_data_set(rf_data_set)
      assert_raise Ecto.NoResultsError, fn -> RFData.get_rf_data_set!(rf_data_set.id) end
    end

    test "change_rf_data_set/1 returns a rf_data_set changeset" do
      rf_data_set = rf_data_set_fixture()
      assert %Ecto.Changeset{} = RFData.change_rf_data_set(rf_data_set)
    end
  end

  describe "rf_measurements" do
    alias RFDataViewer.RFData.RFMeasurement

    import RFDataViewer.RFDataFixtures

    @invalid_attrs %{frequency: nil, gain: nil}

    test "list_rf_measurements/0 returns all rf_measurements" do
      rf_measurement = rf_measurement_fixture()
      assert RFData.list_rf_measurements() == [rf_measurement]
    end

    test "get_rf_measurement!/1 returns the rf_measurement with given id" do
      rf_measurement = rf_measurement_fixture()
      assert RFData.get_rf_measurement!(rf_measurement.id) == rf_measurement
    end

    test "create_rf_measurement/1 with valid data creates a rf_measurements" do
      rf_data_set = RFDataViewer.RFDataFixtures.rf_data_set_fixture()
      valid_attrs = %{type: "lol", frequency: 42, value: 120.5}

      assert {:ok, %RFMeasurement{} = rf_measurement} =
               RFData.create_rf_measurement(rf_data_set, valid_attrs)

      assert rf_measurement.type == "lol"
      assert rf_measurement.frequency == 42
      assert rf_measurement.value == 120.5
    end

    test "create_rf_measurement/1 with invalid data returns error changeset" do
      rf_data_set = RFDataViewer.RFDataFixtures.rf_data_set_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RFData.create_rf_measurement(rf_data_set, @invalid_attrs)
    end

    test "update_rf_measurement/2 with valid data updates the rf_measurement" do
      rf_measurement = rf_measurement_fixture()
      update_attrs = %{type: "lol", frequency: 43, value: 456.7}

      assert {:ok, %RFMeasurement{} = rf_measurement} =
               RFData.update_rf_measurement(rf_measurement, update_attrs)

      assert rf_measurement.type == "lol"
      assert rf_measurement.frequency == 43
      assert rf_measurement.value == 456.7
    end

    test "update_rf_measurement/2 with invalid data returns error changeset" do
      rf_measurement = rf_measurement_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RFData.update_rf_measurement(rf_measurement, @invalid_attrs)

      assert rf_measurement == RFData.get_rf_measurement!(rf_measurement.id)
    end

    test "delete_rf_measurement/1 deletes the rf_measurement" do
      rf_measurement = rf_measurement_fixture()
      assert {:ok, %RFMeasurement{}} = RFData.delete_rf_measurement(rf_measurement)
      assert_raise Ecto.NoResultsError, fn -> RFData.get_rf_measurement!(rf_measurement.id) end
    end

    test "change_rf_measurement/1 returns a rf_measurement changeset" do
      rf_measurement = rf_measurement_fixture()
      assert %Ecto.Changeset{} = RFData.change_rf_measurement(rf_measurement)
    end
  end

  describe "rf_vswr" do
    alias RFDataViewer.RFData.RFVswr

    import RFDataViewer.RFDataFixtures

    @invalid_attrs %{frequency: nil, vswr: nil}

    test "list_rf_vswr/0 returns all rf_vswr" do
      rf_vswr = rf_vswr_fixture()
      assert RFData.list_rf_vswr() == [rf_vswr]
    end

    test "get_rf_vswr!/1 returns the rf_vswr with given id" do
      rf_vswr = rf_vswr_fixture()
      assert RFData.get_rf_vswr!(rf_vswr.id) == rf_vswr
    end

    test "create_rf_vswr/1 with valid data creates a rf_vswr" do
      rf_data_set = RFDataViewer.RFDataFixtures.rf_data_set_fixture()
      valid_attrs = %{frequency: 42, vswr: 120.5}

      assert {:ok, %RFVswr{} = rf_vswr} = RFData.create_rf_vswr(rf_data_set, valid_attrs)
      assert rf_vswr.frequency == 42
      assert rf_vswr.vswr == 120.5
    end

    test "create_rf_vswr/1 with invalid data returns error changeset" do
      rf_data_set = RFDataViewer.RFDataFixtures.rf_data_set_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.create_rf_vswr(rf_data_set, @invalid_attrs)
    end

    test "update_rf_vswr/2 with valid data updates the rf_vswr" do
      rf_vswr = rf_vswr_fixture()
      update_attrs = %{frequency: 43, vswr: 456.7}

      assert {:ok, %RFVswr{} = rf_vswr} = RFData.update_rf_vswr(rf_vswr, update_attrs)
      assert rf_vswr.frequency == 43
      assert rf_vswr.vswr == 456.7
    end

    test "update_rf_vswr/2 with invalid data returns error changeset" do
      rf_vswr = rf_vswr_fixture()
      assert {:error, %Ecto.Changeset{}} = RFData.update_rf_vswr(rf_vswr, @invalid_attrs)
      assert rf_vswr == RFData.get_rf_vswr!(rf_vswr.id)
    end

    test "delete_rf_vswr/1 deletes the rf_vswr" do
      rf_vswr = rf_vswr_fixture()
      assert {:ok, %RFVswr{}} = RFData.delete_rf_vswr(rf_vswr)
      assert_raise Ecto.NoResultsError, fn -> RFData.get_rf_vswr!(rf_vswr.id) end
    end

    test "change_rf_vswr/1 returns a rf_vswr changeset" do
      rf_vswr = rf_vswr_fixture()
      assert %Ecto.Changeset{} = RFData.change_rf_vswr(rf_vswr)
    end
  end
end
