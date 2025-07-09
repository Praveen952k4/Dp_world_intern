using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace InterviewFeedbackSystem.Models
{
    public class InterviewFeedback
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        [Display(Name = "Candidate Name")]
        public string CandidateName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [MaxLength(100)]
        [Display(Name = "Candidate Email")]
        public string CandidateEmail { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [Display(Name = "Position Applied")]
        public string Position { get; set; } = string.Empty;

        [Required]
        [DataType(DataType.Date)]
        [Display(Name = "Interview Date")]
        public DateTime InterviewDate { get; set; }

        [Required]
        [MaxLength(100)]
        [Display(Name = "Interviewer Name")]
        public string InterviewerName { get; set; } = string.Empty;

        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        [Display(Name = "Overall Experience Rating")]
        public int OverallRating { get; set; }

        [Required]
        [Range(1, 5)]
        [Display(Name = "Communication Rating")]
        public int CommunicationRating { get; set; }

        [Required]
        [Range(1, 5)]
        [Display(Name = "Technical Assessment Rating")]
        public int TechnicalRating { get; set; }

        [Required]
        [Range(1, 5)]
        [Display(Name = "Interview Process Rating")]
        public int ProcessRating { get; set; }

        [Required]
        [StringLength(1000, MinimumLength = 10)]
        [Display(Name = "Additional Comments")]
        public string Comments { get; set; } = string.Empty;

        [Display(Name = "Would you recommend our company?")]
        public bool WouldRecommend { get; set; }

        [Display(Name = "Suggestions for Improvement")]
        [StringLength(500)]
        public string? Suggestions { get; set; }

        public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

        // Nullable FK for optional user
        public string? UserId { get; set; }

        public virtual ApplicationUser? User { get; set; }

        [NotMapped]
        public double AverageRating => (OverallRating + CommunicationRating + TechnicalRating + ProcessRating) / 4.0;
    }
}
