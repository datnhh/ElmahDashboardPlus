# Datnhh.Web.Elmah.DashboardPlus
================================

An ASP.NET MVC Dashboard for ELMAH logging.

To install, see: https://www.nuget.org/packages/Datnhh.Web.Elmah.DashboardPlus/ 

(base on https://www.nuget.org/packages/Arebis.Web.Mvc.ElmahDashboard/)

Multiple types were found that match the controller named 'Home'. This can happen if...

To fix this issue, open the `App_Start/RouteConfig.cs` file and replace:

```
routes.MapRoute(
	name: "Default",
	url: "{controller}/{action}/{id}",
	defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional },
	namespaces: new String[] { "ElmahDashboardHostingApp.Controllers" }
);
```



### Securing the ELMAH Dashboard

```
<location path="MvcElmahDashboard">
  <system.web> 
	<authorization> 
	  <allow roles="Administrators"/>
	  <deny users="?"/>
	  <deny users="*"/>
	</authorization>
  </system.web>
</location>
```

### Changing the path to your ELMAH Dashboard

```
public class MvcElmahDashboardAreaRegistration : AreaRegistration 
{
    public override string AreaName 
    {
        get 
        {
            return "MvcElmahDashboard";
        }
    }

    public override void RegisterArea(AreaRegistrationContext context) 
    {
        context.MapRoute(
            name: "MvcElmahDashboard_default",
            url: "<span class="marked">MvcElmahDashboard</span>/{controller}/{action}/{id}",
            defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional },
            namespaces: new string[] { "ElmahDashboardHostingApp.Areas.MvcElmahDashboard.Controllers" }
        );
    }
}
```

### Adding indexes on your [ELMAH_Error] table

```
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_Application] ON [dbo].[ELMAH_Error] ([Application] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_Host] ON [dbo].[ELMAH_Error] ([Host] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_Type] ON [dbo].[ELMAH_Error] ([Type] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_Source] ON [dbo].[ELMAH_Error] ([Source] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_User] ON [dbo].[ELMAH_Error] ([User] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_TimeUtc] ON [dbo].[ELMAH_Error] ([TimeUtc] ASC)
    GO
    CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_Sequence] ON [dbo].[ELMAH_Error] ([Sequence] ASC)
    GO
```