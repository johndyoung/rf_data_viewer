defmodule RFDataViewer.RFDataTest do
  use RFDataViewer.DataCase

  alias RFDataViewer.RFData

  describe "rf_test_set" do
    alias RFDataViewer.RFData.RFTestSet

    import RFDataViewer.RFDataFixtures

    @invalid_attrs %{name: nil, date: nil, description: nil, location: nil}

    test "list_rf_test_set/0 returns all rf_test_set" do
      rf_test_set = rf_test_set_fixture()
      assert RFData.list_rf_test_set() == [rf_test_set]
    end

    test "get_rf_test_set!/1 returns the rf_test_set with given id" do
      rf_test_set = rf_test_set_fixture()
      assert RFData.get_rf_test_set!(rf_test_set.id) == rf_test_set
    end

    test "create_rf_test_set/1 with valid data creates a rf_test_set" do
      valid_attrs = %{name: "some name", date: ~U[2024-08-11 00:57:00Z], description: "some description", location: "some location"}

      assert {:ok, %RFTestSet{} = rf_test_set} = RFData.create_rf_test_set(valid_attrs)
      assert rf_test_set.name == "some name"
      assert rf_test_set.date == ~U[2024-08-11 00:57:00Z]
      assert rf_test_set.description == "some description"
      assert rf_test_set.location == "some location"
    end

    test "create_rf_test_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RFData.create_rf_test_set(@invalid_attrs)
    end

    test "update_rf_test_set/2 with valid data updates the rf_test_set" do
      rf_test_set = rf_test_set_fixture()
      update_attrs = %{name: "some updated name", date: ~U[2024-08-12 00:57:00Z], description: "some updated description", location: "some updated location"}

      assert {:ok, %RFTestSet{} = rf_test_set} = RFData.update_rf_test_set(rf_test_set, update_attrs)
      assert rf_test_set.name == "some updated name"
      assert rf_test_set.date == ~U[2024-08-12 00:57:00Z]
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
      assert RFData.list_rf_data_set() == [rf_data_set]
    end

    test "get_rf_data_set!/1 returns the rf_data_set with given id" do
      rf_data_set = rf_data_set_fixture()
      assert RFData.get_rf_data_set!(rf_data_set.id) == rf_data_set
    end

    test "create_rf_data_set/1 with valid data creates a rf_data_set" do
      valid_attrs = %{name: "some name", date: ~U[2024-08-11 01:05:00Z], description: "some description"}

      assert {:ok, %RFDataSet{} = rf_data_set} = RFData.create_rf_data_set(valid_attrs)
      assert rf_data_set.name == "some name"
      assert rf_data_set.date == ~U[2024-08-11 01:05:00Z]
      assert rf_data_set.description == "some description"
    end

    test "create_rf_data_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RFData.create_rf_data_set(@invalid_attrs)
    end

    test "update_rf_data_set/2 with valid data updates the rf_data_set" do
      rf_data_set = rf_data_set_fixture()
      update_attrs = %{name: "some updated name", date: ~U[2024-08-12 01:05:00Z], description: "some updated description"}

      assert {:ok, %RFDataSet{} = rf_data_set} = RFData.update_rf_data_set(rf_data_set, update_attrs)
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
end
