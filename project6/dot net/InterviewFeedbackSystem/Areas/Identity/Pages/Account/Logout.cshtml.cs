using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;

namespace InterviewFeedbackSystem.Areas.Identity.Pages.Account
{
    public class LogoutModel : PageModel
    {
        public void OnGet()
        {
            // You can clear cookies or session if needed
            HttpContext.Session.Clear();
        }

        public IActionResult OnPost()
        {
            // Handle post-logout if needed
            return RedirectToPage("Login");
        }
    }
}
