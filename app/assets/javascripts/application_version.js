$(document).ready(function () {
    var firstLoad = true;
    var table = null;

    function initializeDataTable(tableID) {
        var processing = false;
        var serverSide = true;
        var paging = true;
        var ordering = false;
        var info = true;
        var searchable = true;
        var searchDelay = 1000;
        var lengthMenu = [10, 20, 50];
        var pagingType = "full_numbers";
        table = $(tableID).DataTable({
            "processing": processing,
            "serverSide": serverSide,
            "searching": searchable,
            "paging": paging,
            "lengthMenu": lengthMenu,
            "ordering": ordering,
            "pagingType": pagingType,
            "info": info,
            "searchDelay": searchDelay,
            "ajax": {
                "url": $().getRequestUrl("./application_versions/get_items"),
                "type": "POST"
            },
            "language": {
                "info": "Showing from _START_ till _END_ from the total of _TOTAL_ records."
            },
            "columns": [
                { "data": "id" },
                { "data": "version_name" },
                { "data": "start_date" },
                { "data": "platform" },
                {
                    "defaultContent": `<div>
                                <a href='#' class='edit-item'>Edit</a>
                                <a href='#' class='delete-item'>Delete</a>
                            </div>`}
            ]
        });

        $(`${tableID} tbody`).on('click', '.edit-item', function (e) {
            e.preventDefault();
            var data = table.row($(this).parents('tr')).data();
            $(this).parents('tr').addClass("selected");
            showVersionForm(data);
        });

        $(`${tableID} tbody`).on('click', '.delete-item', function (e) {
            e.preventDefault();
            var data = table.row($(this).parents('tr')).data();
            $(this).parents('tr').addClass("selected");

            var removeSelectionAction = () => {
                var item = $(tableID).find(".selected");
                if (item) {
                    item.removeClass("selected");
                }
            };
            $().showConfirmationDialog("Delete User", "Are you sure you want to delete this item?",
                () => {
                    deleteItem(data.id);
                },
                () => {
                    removeSelectionAction();
                },
                () => {
                    removeSelectionAction();
                });
        });

        function deleteItem(id) {
            //DELETE FIRST
            $().makeHttpRequest($().getRequestUrl("./application_versions/delete_item?id=" + id), "GET", null, (res) => {
                var item = $(tableID).find(".selected");
                $(tableID).dataTable().api().row(item).remove().draw();

                if (item) {
                    item.removeClass("selected");
                }
            });
        }

        function showVersionForm(data) {
            var model = {
                id: -1,
                version_name: "",
                start_date: new Date().toISOString().split("T")[0],
                platform: "web",
                description: ""
            };
            if (data != null) {
                Object.assign(model, data);
            }

            var forUpdate = model.id > 0;
            var formHtml = `<form id="versionForm">
            <div class="form-group" style="display: none;">
                <label for="id" class="col-md-4 col-form-label text-md-right left-align">Version
                ID</label>
                <div >
                    <input type="text" id="id" class="form-control" name="id"
                        value="${model.id}" />
                </div>
            </div>
            <div class="form-group">
                <label for="version_name" class="col-md-4 col-form-label text-md-right left-align">Version
                    Name</label>
                <div >
                    <input type="text" id="version_name" class="form-control" maxlength="30" name="version_name" required="true"
                          value="${model.version_name}" />
                </div>
            </div>
          
            <div class="form-group">
                <label for="description"
                    class="col-md-4 col-form-label text-md-right left-align">Description
                </label>
                <div >
                    <textarea id="description" class="form-control" name="description"
                        required="true" value="" >${model.description}</textarea>
                </div>
            </div>
          
            <div class="form-group">
                <label for="start_date" class="col-md-4 col-form-label text-md-right left-align">Start
                    Date</label>
                <div >
                    <input type="date" id="start_date" class="form-control" name="start_date" value="${
                model.start_date
                }"  />
                </div>
            </div>
          
            <div class="form-group">
                <label for="platform" class="col-md-4 col-form-label text-md-right left-align">Platform</label>
                <div >
                <select class="form-control" id="platform">
    <option ${model.platform == "web" ? "selected" : ""}>web</option>
    <option ${model.platform == "android" ? "selected" : ""}>android</option>
    <option ${model.platform == "ios" ? "selected" : ""}>ios</option>
  </select>
                </div>
            </div>
          
            <div class="col-md-6 offset-md-4">
                <button type="submit" class="btn btn-primary">
                    Save
                </button>
            </div>
          </form>`;

            $().showHtmlDialog(
                forUpdate ? "Update Version" : "Create new Version",
                formHtml, () => {
                    var item = $(tableID).find(".selected");
                    if (item) {
                        item.removeClass("selected");
                    }
                }
            );

            $("#versionForm #description").ckeditor();

            $("#versionForm").submit(function (e) {
                e.preventDefault();
                var form = $(this);

                var dataToSave = $().getFormData(form, {
                    id: -1,
                    version_name: "",
                    start_date: "",
                    platform: $("#versionForm #platform")[0].value,
                    description: ""
                });

                $().makeHttpRequest($().getRequestUrl("./application_versions/edit_item"), "POST", { version: dataToSave }, (data) => {
                    if (dataToSave.id > 0) {
                        var item = $(tableID).find(".selected");
                        $(tableID).dataTable().fnUpdate(data, item.index(), undefined, false);

                        if (item) {
                            item.removeClass("selected");
                        }
                    }
                    else {
                        $(tableID).dataTable().api().row.add(data).draw();
                    }
                    $().hideHtmlDialog();
                }, (error) => {
                    $().showMessage("Error", error);
                    var item = $(tableID).find(".selected");
                    if (item) {
                        item.removeClass("selected");
                    }
                });
            });
        }

        $("#addNewVersion").on("click", () => {
            showVersionForm(null);
        });
    }

    $("#versionPanelMenu").on("click", () => {
        if (firstLoad) {
            firstLoad = false;
            initializeDataTable("#versionTable");
            setTimeout(() => {
                if ($("#versionTable")[0].style.width == "0px") {
                    $("#versionTable").dataTable().api().columns.adjust().draw();
                }
            }, 1000)
        }
    })
});
