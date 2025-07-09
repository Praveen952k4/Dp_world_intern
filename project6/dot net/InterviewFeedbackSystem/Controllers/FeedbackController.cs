using InterviewFeedbackSystem.Data;
using InterviewFeedbackSystem.Models;
using InterviewFeedbackSystem.Models.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace InterviewFeedbackSystem.Controllers
{
    [Authorize]
    public class FeedbackController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public FeedbackController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // GET: Feedback
        [Authorize(Roles = "HR,Admin")]
        public async Task<IActionResult> Index(string searchString, string position, string interviewer, DateTime? fromDate, DateTime? toDate)
        {
            var feedbacks = _context.InterviewFeedbacks.AsQueryable();

            if (!string.IsNullOrEmpty(searchString))
            {
                feedbacks = feedbacks.Where(f => f.CandidateName.Contains(searchString) || 
                                                f.CandidateEmail.Contains(searchString));
            }

            if (!string.IsNullOrEmpty(position))
            {
                feedbacks = feedbacks.Where(f => f.Position.Contains(position));
            }

            if (!string.IsNullOrEmpty(interviewer))
            {
                feedbacks = feedbacks.Where(f => f.InterviewerName.Contains(interviewer));
            }

            if (fromDate.HasValue)
            {
                feedbacks = feedbacks.Where(f => f.InterviewDate >= fromDate.Value);
            }

            if (toDate.HasValue)
            {
                feedbacks = feedbacks.Where(f => f.InterviewDate <= toDate.Value);
            }

            ViewData["CurrentFilter"] = searchString;
            ViewData["PositionFilter"] = position;
            ViewData["InterviewerFilter"] = interviewer;
            ViewData["FromDateFilter"] = fromDate?.ToString("yyyy-MM-dd");
            ViewData["ToDateFilter"] = toDate?.ToString("yyyy-MM-dd");

            var result = await feedbacks.OrderByDescending(f => f.SubmittedAt).ToListAsync();
            return View(result);
        }

        // GET: Feedback/Details/5
        [Authorize(Roles = "HR,Admin")]
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var feedback = await _context.InterviewFeedbacks
                .Include(f => f.User)
                .FirstOrDefaultAsync(m => m.Id == id);
            
            if (feedback == null)
            {
                return NotFound();
            }

            return View(feedback);
        }

        // GET: Feedback/Create
        public IActionResult Create()
        {
            var model = new FeedbackViewModel
            {
                InterviewDate = DateTime.SpecifyKind(DateTime.Today, DateTimeKind.Utc) // ✅ set DateTimeKind
            };
            return View(model);
        }

        // POST: Feedback/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(FeedbackViewModel model)
        {
            if (ModelState.IsValid)
            {
                var feedback = new InterviewFeedback
                {
                    CandidateName = model.CandidateName,
                    CandidateEmail = model.CandidateEmail,
                    Position = model.Position,
                    InterviewDate = DateTime.SpecifyKind(model.InterviewDate, DateTimeKind.Utc), // ✅ ensure UTC
                    InterviewerName = model.InterviewerName,
                    OverallRating = model.OverallRating,
                    CommunicationRating = model.CommunicationRating,
                    TechnicalRating = model.TechnicalRating,
                    ProcessRating = model.ProcessRating,
                    Comments = model.Comments,
                    WouldRecommend = model.WouldRecommend,
                    Suggestions = model.Suggestions,
                    UserId = _userManager.GetUserId(User),
                    SubmittedAt = DateTime.UtcNow // ✅ UTC-safe
                };

                _context.Add(feedback);
                await _context.SaveChangesAsync();
                
                TempData["SuccessMessage"] = "Thank you for your feedback! Your response has been submitted successfully.";
                return RedirectToAction(nameof(Create));
            }
            return View(model);
        }

        // GET: Feedback/MyCandidateFeedback
        [Authorize(Roles = "Candidate")]
        public async Task<IActionResult> MyCandidateFeedback()
        {
            var userId = _userManager.GetUserId(User);
            var feedbacks = await _context.InterviewFeedbacks
                .Where(f => f.UserId == userId)
                .OrderByDescending(f => f.SubmittedAt)
                .ToListAsync();

            return View(feedbacks);
        }

        // GET: Feedback/Delete/5
        [Authorize(Roles = "HR,Admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var feedback = await _context.InterviewFeedbacks
                .FirstOrDefaultAsync(m => m.Id == id);
            if (feedback == null)
            {
                return NotFound();
            }

            return View(feedback);
        }

        // POST: Feedback/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "HR,Admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var feedback = await _context.InterviewFeedbacks.FindAsync(id);
            if (feedback != null)
            {
                _context.InterviewFeedbacks.Remove(feedback);
                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(Index));
        }
    }
}
