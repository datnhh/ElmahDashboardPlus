@model $rootnamespace$.Areas.MvcElmahDashboard.Models.Logs.DetailsModel
@{
    ViewBag.Title = "Details";
}
@section head
{
    <script src="@(Url.Action("Details_scripts", new { v = Html.ScriptsVersion() }))"></script>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>
}

<div id="details-content">
    @Html.Action("ItemDetails", new { id = Model.Id })
</div>

<div id="useragent-dlg" class="modal">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">User Agent information<br/><small class="value-holder"></small></h4>
            </div>
            <div class="modal-body">
                <div class="loader">
                    Loading...
                </div>
                <div class="data hidden">
                    <table class="table table-striped table-condensed"></table>
                    <p class="small">Powered by: <a href="@(Model.UserAgentInfoProvider.InfoUrl)" target="_blank">@(Model.UserAgentInfoProvider.Caption)</a></p>
                </div>
                <div class="error hidden">
                    An error occured...
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div id="remoteaddr-dlg" class="modal">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">Remote Address information <small class="value-holder"></small></h4>
            </div>
            <div class="modal-body">
                <div class="loader">
                    Loading...
                </div>
                <div class="data hidden">
                    <div id="google-map" style="width: 100%; height: 200px; border: solid 1px gray;"></div>
                    <table class="table table-striped table-condensed"></table>
                    <p class="small" style="margin-top: 6px;">Powered by: <a href="@(Model.RemoteAddressInfoProvider.InfoUrl)" target="_blank">@(Model.RemoteAddressInfoProvider.Caption)</a> &amp; <a href="http://maps.google.com/" target="_blank">Google Maps</a>.</p>
                </div>
                <div class="error hidden">
                    An error occured...
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
