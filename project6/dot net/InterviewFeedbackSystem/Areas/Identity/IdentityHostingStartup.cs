using Microsoft.AspNetCore.Hosting;

[assembly: HostingStartup(typeof(InterviewFeedbackSystem.Areas.Identity.IdentityHostingStartup))]
namespace InterviewFeedbackSystem.Areas.Identity
{
    public class IdentityHostingStartup : IHostingStartup
    {
        public void Configure(IWebHostBuilder builder)
        {
            builder.ConfigureServices((context, services) => {
            });
        }
    }
}