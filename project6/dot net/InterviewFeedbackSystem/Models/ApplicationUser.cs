using Microsoft.AspNetCore.Identity;

namespace InterviewFeedbackSystem.Models
{
    public class ApplicationUser : IdentityUser
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Department { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public string FullName => $"{FirstName} {LastName}";
        
        // Navigation property
        public virtual ICollection<InterviewFeedback> InterviewFeedbacks { get; set; } = new List<InterviewFeedback>();
    }
}