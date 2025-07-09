# Interview Feedback System

A comprehensive ASP.NET Core web application for collecting and managing interview feedback from candidates.

## 🚀 Features

### For Candidates
- **Submit Feedback**: Share detailed interview experiences with ratings and comments
- **View History**: Access personal feedback history and track submissions
- **User-Friendly Interface**: Modern, responsive design with intuitive navigation

### For HR/Admin
- **Dashboard Analytics**: View comprehensive statistics and insights
- **Feedback Management**: Browse, search, and filter all feedback submissions
- **Detailed Reports**: Access individual feedback details with full context
- **Role-Based Access**: Secure access control with different permission levels

## 🛠️ Technology Stack

- **Framework**: ASP.NET Core 8.0
- **Database**: SQL Server with Entity Framework Core
- **Authentication**: ASP.NET Core Identity
- **Frontend**: Bootstrap 5, jQuery, Bootstrap Icons
- **Architecture**: MVC Pattern with Razor Pages

## 📋 Prerequisites

- Visual Studio 2022 (or Visual Studio Code)
- .NET 8.0 SDK
- SQL Server LocalDB (included with Visual Studio)

## 🚀 Getting Started

### 1. Clone or Download the Project
```bash
git clone [repository-url]
cd InterviewFeedbackSystem
```

### 2. Open in Visual Studio
- Open `InterviewFeedbackSystem.sln` in Visual Studio 2022

### 3. Set Up Database
Open **Package Manager Console** (Tools → NuGet Package Manager → Package Manager Console) and run:
```powershell
Add-Migration InitialCreate
Update-Database
```

### 4. Run the Application
- Press **F5** or click **Start Debugging**
- The application will open in your default browser

## 👥 Demo Accounts

The application comes with pre-seeded demo accounts:

### HR Manager Account
- **Email**: `hr@company.com`
- **Password**: `Admin123!`
- **Access**: Full dashboard, view all feedback, analytics

### Candidate Account
- **Email**: `john.doe@email.com`
- **Password**: `Candidate123!`
- **Access**: Submit feedback, view personal history

## 📊 Key Features Explained

### Dashboard Analytics
- Total feedback count and trends
- Average ratings across all submissions
- Recommendation rates and statistics
- Position-wise feedback distribution
- Interviewer performance metrics

### Feedback Form
- Comprehensive rating system (1-5 stars)
- Multiple rating categories:
  - Overall Experience
  - Communication
  - Technical Assessment
  - Interview Process
- Detailed comments and suggestions
- Company recommendation toggle

### Search & Filter
- Search by candidate name or email
- Filter by position, interviewer, or date range
- Real-time filtering with responsive results

### Security Features
- Role-based authentication (HR, Admin, Candidate)
- Secure password requirements
- Session management
- Data validation and sanitization

## 🎨 Design Features

- **Modern UI**: Clean, professional interface using Bootstrap 5
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- **Interactive Elements**: Hover effects, animations, and transitions
- **Accessibility**: WCAG compliant with proper ARIA labels
- **Visual Feedback**: Loading states, success messages, and error handling

## 📁 Project Structure

```
InterviewFeedbackSystem/
├── Controllers/           # MVC Controllers
├── Models/               # Data models and ViewModels
├── Views/                # Razor views and layouts
├── Data/                 # Database context and migrations
├── Areas/Identity/       # Authentication pages
├── wwwroot/             # Static files (CSS, JS, images)
└── Program.cs           # Application startup
```

## 🔧 Configuration

### Database Connection
The application uses SQL Server LocalDB by default. Connection string in `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=InterviewFeedback.db"
  }
}
```

### Authentication Settings
Password requirements are configured in `Program.cs` for development ease:
- Minimum length: 6 characters
- No special character requirements
- Email confirmation disabled

## 🚀 Deployment

### For Production Deployment:
1. Update connection strings for production database
2. Enable stronger password requirements
3. Configure email confirmation
4. Set up HTTPS certificates
5. Configure logging and monitoring

## 📝 Usage Guide

### For Candidates:
1. Register or login with candidate credentials
2. Navigate to "Submit Feedback"
3. Fill out the comprehensive feedback form
4. View your submission history in "My Feedback"

### For HR/Admin:
1. Login with HR credentials
2. Access the dashboard for overview analytics
3. Use "All Feedback" to browse and search submissions
4. Click on individual entries for detailed views
5. Use filters to find specific feedback

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation
- Review the demo accounts and features
- Submit issues for bugs or feature requests

## 🔄 Version History

- **v1.0.0**: Initial release with core functionality
  - User authentication and authorization
  - Feedback submission and management
  - Dashboard analytics
  - Responsive design
  - Demo data seeding

---

**Built with ❤️ using ASP.NET Core and Bootstrap**