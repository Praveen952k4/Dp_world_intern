using InterviewFeedbackSystem.Data;
using InterviewFeedbackSystem.Models;
using InterviewFeedbackSystem.Models.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Diagnostics;

namespace InterviewFeedbackSystem.Controllers
{
    public class HomeController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<HomeController> _logger;

        public HomeController(ApplicationDbContext context, ILogger<HomeController> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                if (User.IsInRole("HR") || User.IsInRole("Admin"))
                {
                    // HR Dashboard
                    var totalFeedbacks = await _context.InterviewFeedbacks.CountAsync();
                    var averageRating = await _context.InterviewFeedbacks
                        .AverageAsync(f => (double?)f.OverallRating) ?? 0;
                    var recommendationCount = await _context.InterviewFeedbacks
                        .CountAsync(f => f.WouldRecommend);
                    var recentFeedbacks = await _context.InterviewFeedbacks
                        .OrderByDescending(f => f.SubmittedAt)
                        .Take(5)
                        .ToListAsync();

                    var positionStats = await _context.InterviewFeedbacks
                        .GroupBy(f => f.Position)
                        .Select(g => new { Position = g.Key, Count = g.Count() })
                        .ToDictionaryAsync(x => x.Position, x => x.Count);

                    var interviewerRatings = await _context.InterviewFeedbacks
                        .GroupBy(f => f.InterviewerName)
                        .Select(g => new { 
                            Interviewer = g.Key, 
                            AvgRating = g.Average(f => f.OverallRating) 
                        })
                        .ToDictionaryAsync(x => x.Interviewer, x => x.AvgRating);

                    var dashboardViewModel = new FeedbackDashboardViewModel
                    {
                        TotalFeedbacks = totalFeedbacks,
                        AverageRating = averageRating,
                        RecommendationCount = recommendationCount,
                        RecentFeedbacks = recentFeedbacks,
                        PositionStats = positionStats,
                        InterviewerRatings = interviewerRatings
                    };

                    return View("HRDashboard", dashboardViewModel);
                }
                else
                {
                    // Candidate Dashboard
                    return RedirectToAction("MyCandidateFeedback", "Feedback");
                }
            }

            // Public landing page
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}