$(function () {
    jQuery.fn.extend({
        showConfirmationDialog: function (title, message, yesAction, noAction, closeAction) {
            var modalHtml = `<div class="modal fade" id="confirmationModal" role="dialog">
            <div class="modal-dialog err-pop" style="">
                <div class="modal-content" style ="width: auto !important;">
                    <div class="modal-header"> ${title}
                        <button id="divClose" type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div id="modalBody" class="modal-body" style="text-align:center;">
                        ${message} <br/>
                        <button id="yesButton" class="btn btn-primary">Yes</button>
                        <button id="noButton" class="btn btn-secondary">No</button>
                    </div>
                </div>
            </div>
          </div>`;

            var removeConfirmAction = () => {
                var dialog = $("#confirmationModal");
                if (dialog) {
                    dialog
                        .on("hidden.bs.modal", () => {
                            $(dialog).remove();
                        })
                        .modal("hide");
                }
            };

            $(modalHtml)
                .appendTo(document.body)
                .modal({ show: true, backdrop: 'static', keyboard: false })
                .on("click", "#divClose", function () {
                    if (closeAction) closeAction();
                    removeConfirmAction();
                })
                .on("click", "#yesButton", function () {
                    if (yesAction) yesAction();
                    removeConfirmAction();
                })
                .on("click", "#noButton", function () {
                    if (noAction) noAction();
                    removeConfirmAction();
                });
        },
        showMessage: function (title, message) {
            alert(message);
        },
        showHtmlDialog: function (title, body, closeAction = null) {
            var modalHtml = `<div class="modal fade" id="modalDialog" role="dialog">
                                        <div class="modal-dialog err-pop" style="">
                                            <div class="modal-content" style="width: auto !important;">
                                                <div class="modal-header">
                                                ${title}
                                                    <button id="divClose" type="button" class="close" data-dismiss="modal">&times;</button>
                                                </div>
                                                <div id="modalBody" class="modal-body" style="text-align:center;">
                                                   ${body}
                                                </div>
                                            </div>
                                        </div>
                                      </div>`;

            var removeConfirmAction = () => {
                var dialog = $("#modalDialog");
                if (dialog) {
                    dialog
                        .on("hidden.bs.modal", () => {
                            $(dialog).remove();
                        })
                        .modal("hide");
                }
            };

            var prevDialog = $("#modalDialog");
            if (prevDialog) {
                $(prevDialog).remove();
            }

            $(modalHtml)
                .appendTo(document.body)
                .modal({ show: true, backdrop: 'static', keyboard: false })
                .on("click", "#divClose", function () {
                    removeConfirmAction();
                    if (closeAction) closeAction();
                });
        },
        hideHtmlDialog: function () {
            var dialog = $("#modalDialog");
            if (dialog) {
                dialog.modal("hide");
            }
            var modal = $(".modal-backdrop")[0];
            if (modal) {
                modal.parentNode.removeChild(modal);
            }
        },
        getFormData: function ($form, model = null) {
            var unindexed_array = $form.serializeArray();
            var indexed_array = {};
            if (model != null) {
                indexed_array = model;
            }
            $.map(unindexed_array, function (n, i) {
                indexed_array[n["name"]] = n["value"];
            });

            return indexed_array;
        },
        makeHttpRequest: function (url,
            method = "GET",
            data = null,
            successAction = null,
            failureAction = null) {
            if (data == null) data = {};
            if (method == "POST") {
                data = JSON.stringify(data);
            }
            $.ajax({
                url: url,
                method: method,
                contentType: "application/json; charset=utf-8",
                data: data,
                success: function (res) {
                    if (res.status) {
                        if (successAction) successAction(res.result);
                    } else {
                        if (failureAction) failureAction(res.message);
                    }
                },
                error: function (xhr) {
                    if (xhr.status != 401) {
                        if (failureAction) failureAction();
                    }
                },
            });
        },
        getRequestUrl: function (path) {
            return window.location.origin + "/" + path;
        }
    });
});