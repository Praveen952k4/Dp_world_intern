using InterviewFeedbackSystem.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace InterviewFeedbackSystem.Data
{
    public static class SeedData
    {
        public static async Task Initialize(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();

            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
            var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

            // Apply pending migrations (safe for PostgreSQL)
            await context.Database.MigrateAsync();

            // Create roles
            string[] roleNames = { "HR", "Candidate", "Admin" };
            foreach (var roleName in roleNames)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    await roleManager.CreateAsync(new IdentityRole(roleName));
                }
            }

            // Create HR user
            var hrEmail = "hr@company.com";
            var hrUser = await userManager.FindByEmailAsync(hrEmail);
            if (hrUser == null)
            {
                hrUser = new ApplicationUser
                {
                    UserName = hrEmail,
                    Email = hrEmail,
                    FirstName = "HR",
                    LastName = "Manager",
                    Department = "Human Resources",
                    EmailConfirmed = true
                };

                var hrResult = await userManager.CreateAsync(hrUser, "Admin123!");
                if (hrResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(hrUser, "HR");
                    await userManager.AddToRoleAsync(hrUser, "Admin");
                }
                else
                {
                    throw new Exception("Failed to create HR user: " + string.Join(", ", hrResult.Errors.Select(e => e.Description)));
                }
            }

            // Create Candidate user
            var candidateEmail = "john.doe@email.com";
            var candidateUser = await userManager.FindByEmailAsync(candidateEmail);
            if (candidateUser == null)
            {
                candidateUser = new ApplicationUser
                {
                    UserName = candidateEmail,
                    Email = candidateEmail,
                    FirstName = "John",
                    LastName = "Doe",
                    Department = "Engineering",
                    EmailConfirmed = true
                };

                var candidateResult = await userManager.CreateAsync(candidateUser, "Candidate123!");
                if (candidateResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(candidateUser, "Candidate");
                }
                else
                {
                    throw new Exception("Failed to create candidate user: " + string.Join(", ", candidateResult.Errors.Select(e => e.Description)));
                }
            }

            // Seed Interview Feedbacks only if table is empty
            if (!await context.InterviewFeedbacks.AnyAsync())
            {
                var sampleFeedbacks = new List<InterviewFeedback>
                {
                    new InterviewFeedback
                    {
                        CandidateName = "John Doe",
                        CandidateEmail = candidateUser.Email,
                        Position = "Software Developer",
                        InterviewDate = DateTime.UtcNow.AddDays(-5),
                        InterviewerName = "Sarah Johnson",
                        OverallRating = 4,
                        CommunicationRating = 5,
                        TechnicalRating = 4,
                        ProcessRating = 4,
                        Comments = "Great interview experience. The technical questions were challenging but fair.",
                        WouldRecommend = true,
                        Suggestions = "Maybe provide more details about the company culture during the interview.",
                        UserId = candidateUser.Id,
                        SubmittedAt = DateTime.UtcNow.AddDays(-5)
                    },
                    new InterviewFeedback
                    {
                        CandidateName = "Alice Smith",
                        CandidateEmail = "alice.smith@email.com",
                        Position = "UI/UX Designer",
                        InterviewDate = DateTime.UtcNow.AddDays(-3),
                        InterviewerName = "Mike Chen",
                        OverallRating = 5,
                        CommunicationRating = 5,
                        TechnicalRating = 5,
                        ProcessRating = 5,
                        Comments = "Excellent interview process. Very well organized.",
                        WouldRecommend = true,
                        Suggestions = "Everything was perfect!",
                        SubmittedAt = DateTime.UtcNow.AddDays(-3)
                    },
                    new InterviewFeedback
                    {
                        CandidateName = "Robert Wilson",
                        CandidateEmail = "robert.wilson@email.com",
                        Position = "Data Analyst",
                        InterviewDate = DateTime.UtcNow.AddDays(-1),
                        InterviewerName = "Lisa Brown",
                        OverallRating = 3,
                        CommunicationRating = 4,
                        TechnicalRating = 3,
                        ProcessRating = 3,
                        Comments = "The interview was okay, but some questions felt off-topic.",
                        WouldRecommend = false,
                        Suggestions = "Better time management and more relevant questions.",
                        SubmittedAt = DateTime.UtcNow.AddDays(-1)
                    }
                };

                context.InterviewFeedbacks.AddRange(sampleFeedbacks);
                await context.SaveChangesAsync();
            }
        }
    }
}
