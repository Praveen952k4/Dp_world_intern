using InterviewFeedbackSystem.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace InterviewFeedbackSystem.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<InterviewFeedback> InterviewFeedbacks { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<InterviewFeedback>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.CandidateName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.CandidateEmail).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Position).IsRequired().HasMaxLength(100);
                entity.Property(e => e.InterviewerName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Comments).IsRequired().HasMaxLength(1000);
                entity.Property(e => e.Suggestions).HasMaxLength(500);

                entity.HasOne(e => e.User)
                      .WithMany(u => u.InterviewFeedbacks)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.SetNull); // Only if UserId is nullable
            });
        }
    }
}
