using System.ComponentModel.DataAnnotations;

namespace InterviewFeedbackSystem.Models.ViewModels
{
    public class FeedbackViewModel
    {
        [Required]
        [Display(Name = "Candidate Name")]
        public string CandidateName { get; set; } = string.Empty;
        
        [Required]
        [EmailAddress]
        [Display(Name = "Candidate Email")]
        public string CandidateEmail { get; set; } = string.Empty;
        
        [Required]
        [Display(Name = "Position Applied")]
        public string Position { get; set; } = string.Empty;
        
        [Required]
        [Display(Name = "Interview Date")]
        [DataType(DataType.Date)]
        public DateTime InterviewDate { get; set; }
        
        [Required]
        [Display(Name = "Interviewer Name")]
        public string InterviewerName { get; set; } = string.Empty;
        
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        [Display(Name = "Overall Experience Rating")]
        public int OverallRating { get; set; }
        
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        [Display(Name = "Communication Rating")]
        public int CommunicationRating { get; set; }
        
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        [Display(Name = "Technical Assessment Rating")]
        public int TechnicalRating { get; set; }
        
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        [Display(Name = "Interview Process Rating")]
        public int ProcessRating { get; set; }
        
        [Required]
        [StringLength(1000, MinimumLength = 10, ErrorMessage = "Comments must be between 10 and 1000 characters")]
        [Display(Name = "Additional Comments")]
        public string Comments { get; set; } = string.Empty;
        
        [Display(Name = "Would you recommend our company?")]
        public bool WouldRecommend { get; set; }
        
        [Display(Name = "Suggestions for Improvement")]
        [StringLength(500)]
        public string? Suggestions { get; set; }
    }
    
    public class FeedbackDashboardViewModel
    {
        public int TotalFeedbacks { get; set; }
        public double AverageRating { get; set; }
        public int RecommendationCount { get; set; }
        public List<InterviewFeedback> RecentFeedbacks { get; set; } = new();
        public Dictionary<string, int> PositionStats { get; set; } = new();
        public Dictionary<string, double> InterviewerRatings { get; set; } = new();
    }
}