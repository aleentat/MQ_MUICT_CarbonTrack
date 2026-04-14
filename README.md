# Carbon Diary - Real-Time Emissions Monitoring App for Daily Activities

A comprehensive Flutter mobile application that empowers users to track and reduce their daily carbon emissions through activity logging, environmental awareness, and gamified eco-friendly behavior tracking.

## Project Overview

**Carbon Diary** is an environmental impact tracking application that allows users to log daily activities and calculate their carbon emissions using standardized emission factors. The system combines multi-category tracking (travel, waste, food, and shopping) with visual analytics and gamification to encourage long-term sustainable behavior.

### Key Features

- **Travel Carbon Calculator** - Track CO2 emissions from various transportation modes (car, bus, motorcycle, train, airplane)
- **Eating Carbon Calculator** - Log food consumption and calculate its carbon impact
- **Shopping Carbon Calculator** - Track emissions from shopping activities and consumer goods
- **Waste Carbon Calculator** - Learn proper waste disposal categories with visual guides
- **Carbon Diary** - Journal-style activity log with detailed breakdown by date and type
- **Statistics & Analytics** - Visualize carbon trends with charts and weekly eco-scores
- **Gamification** - Virtual tree growth system that reflects environmental impact

### Other Features

- **Daily Notifications** - Reminder notifications to encourage consistent tracking
- **User Profile** - Personalized settings and progress tracking
- **Tutorial System** - Interactive on-boarding guide using coach marks

## Project Goals

This application aims to:
1. **Raise Awareness** - Help users understand the carbon impact of daily decisions
2. **Encourage Eco-Friendly Choices** - Use positive reinforcement through visual feedback (tree growth)
3. **Track Progress** - Monitor improvements in environmental impact over time
4. **Educate** - Provide information about waste management and sustainable practices
5. **Motivate Behavior Change** - Gamification mechanics to maintain user engagement

## Technical Stack

### Core Dependencies
- **Database**: `sqflite` - Lightweight SQLite wrapper for local data persistence
- **Notifications**: `flutter_local_notifications`, `timezone` - Push notification scheduling
- **UI Components**: 
  - `convex_bottom_bar` - Custom bottom navigation bar
  - `table_calendar` - Calendar widget for activity tracking
  - `fl_chart` - Data visualization and charts
  - `lottie` - Animation support
  - `google_fonts` - Typography styling
  - `tutorial_coach_mark` - Interactive on-boarding

### Services & APIs
- **Location Services**: `google_place` - Autocomplete search for locations
- **Image Handling**: `image_picker` - Photo capture and selection
- **File Management**: `path_provider`, `path` - File system operations
- **Networking**: `http` - API requests
- **Sharing**: `share_plus` - Share functionality
- **Local Storage**: `shared_preferences` - Persistent user preferences
- **Environment Config**: `flutter_dotenv` - Configuration management
- **Internationalization**: `intl` - Localization support
- **URL Handling**: `url_launcher` - Deep linking and external URLs

## Data Models

### Diary Entries
Each diary entry type (Travel, Eating, Shopping, Waste) contains:
- **Type**: Category of activity
- **Description**: User notes or details
- **Carbon Emissions**: Calculated CO2 equivalent (kg)
- **Timestamp**: When the activity occurred
- **Metadata**: Activity-specific details (e.g., distance for travel, food type for eating)

### Eco-Score System
- **Weekly Score**: Aggregated carbon impact across 7 days
- **Tree Growth**: Virtual tree that grows/shrinks based on eco-score performance
- **Statistics**: Weekly/monthly trends and comparisons

## Gamification System

The app includes a gamified avatar system:
- **Tree Avatar**: Visual representation of user's environmental impact
- **Weekly Reset**: Eco-score calculated weekly to maintain motivation
- **Progress Tracking**: Historical data to show improvement over time
- **Visual Feedback**: Tree health directly reflects carbon reduction efforts

## Database

- **SQLite**: Local relational database for offline-first functionality
- **Auto-initialization**: Database creates tables and initializes on first launch
- **App Open Tracking**: Tracks app usage metrics for engagement analysis

## Statistics Service & Daily Summary Processing

The `StatisticService` is responsible for aggregating user activity data and generating a **daily carbon emission summary**. This summary is used for analytics, eco-score calculation, and optional cloud synchronization.

### Overview

The service collects data from all activity modules:

- Travel  
- Waste  
- Eating  
- Shopping  

It then computes total emissions, log counts, and eco-scores before sending the result to an external API.

### Workflow

1. **Retrieve Data from Local Database**
   - Uses `DBHelper` to fetch all diary entries:
     - Travel entries  
     - Waste entries  
     - Eating entries  
     - Shopping entries  

2. **Calculate CO₂ Emissions**
   - Each category is summed using:
     ```dart
     total = entries.fold(0, (sum, entry) => sum + entry.carbon);
     ```

3. **Aggregate Daily Metrics**
   - Total number of logs  
   - Total CO₂ emissions  
   - CO₂ breakdown by category  

4. **Fetch User Metadata**
   - Username (generated or stored)  
   - Age (from user profile)  
   - App usage count (daily opens)  

5. **Compute Eco-Score**
   - Uses:
     ```dart
     EcoScoreCalculator.dailyScore(totalDailyCO2)
     ```
   - Converts emission value into a sustainability score

6. **Create Summary Object**
   - Structured using the `UsageSummary` model

7. **Send Data to API**
   - Summary is sent via `ApiService` for storage or analysis

---

## Notifications

- **Daily Reminders**: Optional 8 AM notifications to encourage logging
- **User Preference**: Toggle notification settings in user profile
- **Timezone Support**: Adapts to user's local timezone

## Features & Workflows

### Activity Logging Flow
1. User selects activity type (Travel, Food, Shopping, or Waste)
2. Input relevant details (e.g., transport mode, distance; food type; shopping items)
3. App calculates carbon emissions using standardized formulas
4. Activity stored in local database with timestamp
5. Weekly eco-score updated automatically

### Waste Management
- Interactive guide with waste categories
- Items sorted by proper disposal methods
- Educational information about recycling
- Logging capability for waste activities

### Analytics
- Weekly and monthly carbon trend charts
- Comparison of activities by type
- Historical eco-score tracking
- Usage statistics and insights


## Important Implementation Notes

### Calculations & Data Sources
- **Carbon Emissions Formulas**: Based on TCCT source code and preliminary research
- **Emission Factors**: Standardized conversion factors for different activities and transportation modes
- **Research Status**: Current calculations are estimates. More rigorous research and proper academic references will be integrated in future versions

### Architecture Decisions
- **Offline-First**: All calculations and storage happen locally using SQLite
- **No Cloud Sync**: Currently designed for single-device use (sync service available for future integration)
- **State Management**: Stateful widgets with callbacks for reactive UI updates
- **Material Design**: Follows Flutter Material Design 3 guidelines


## Contributing

When contributing to this project:
1. Follow Dart/Flutter best practices and style guidelines
2. Update relevant models and documentation
3. Test new features thoroughly across platforms
4. Submit pull requests with clear descriptions

## License

Danai Suwantanee
Aleenta Tangcharoensukwong

## Author & Contact

**Project**: MQ MUICT Carbon Track
**Purpose**: Environmental Impact Tracking & Awareness
**Status**: Active Development

---

**Note**: This application is designed to raise environmental awareness and encourage sustainable living practices. While the carbon calculations are based on available research, users should verify specific data for professional or official purposes.