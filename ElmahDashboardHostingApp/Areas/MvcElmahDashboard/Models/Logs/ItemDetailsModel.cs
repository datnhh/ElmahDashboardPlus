using System;

namespace $rootnamespace$.Areas.MvcElmahDashboard.Models.Logs
{
    public class ItemDetailsModel
    {
        public Code.ElmahError Item { get; set; }

        public dynamic UserAgentInfoProvider { get; set; }

        public dynamic RemoteAddressInfoProvider { get; set; }
    }
}