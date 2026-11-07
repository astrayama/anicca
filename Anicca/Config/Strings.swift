import Foundation

enum Strings {
    enum App {
        static let name = "Anicca"
        static let tagline = "Read your energy. Understand yourself."
    }

    enum Auth {
        static let welcomeTitle = "Welcome to Anicca"
        static let welcomeSubtitle = "Sign in to start tracking your inner weather."
        static let continueWithApple = "Continue with Apple"
        static let continueWithGoogle = "Continue with Google"
        static let signIn = "Sign In"
        static let signUp = "Sign Up"
        static let email = "Email"
        static let password = "Password"
        static let confirmPassword = "Confirm Password"
        static let displayName = "Display Name"
        static let forgotPassword = "Forgot password?"
        static let noAccountPrompt = "Don't have an account? Sign up"
        static let hasAccountPrompt = "Already have an account? Sign in"
        static let or = "or"
        static let resetSent = "Password reset email sent. Check your inbox."
        static let invalidEmail = "Enter a valid email address."
        static let passwordTooShort = "Password must be at least 8 characters."
        static let passwordsDoNotMatch = "Passwords do not match."
        static let displayNameRequired = "Please enter a display name."
        static let confirmEmailSent = "Almost there. We sent a confirmation link to your email. Open it on this iPhone to finish signing in."
        static let confirmEmailFirst = "Please confirm your email first. Open the link we sent you, then sign in."
        static let confirmLinkFailed = "We couldn't sign you in from that link. Sign in with your email and password instead."
    }

    enum Onboarding {
        static let step1Title = "Your inner world has a map."
        static let step1Body = "Anicca helps you tune in to seven distinct centers of energy — each one a layer of how you feel, think, and move through the day."
        static let step2Title = "The 7 Centers"
        static let step2Body = "Each center represents a different aspect of your experience. Tap a center to learn more."
        static let step3Title = "How check-ins work"
        static let step4Title = "Gentle reminders"
        static let step4Body = "We'll nudge you once a day to check in. No streaks to chase — just a soft invitation to listen."
        static let enableReminders = "Enable Reminders"
        static let maybeLater = "Maybe Later"
        static let next = "Next"
        static let skip = "Skip"
        static let getStarted = "Get Started"
    }

    enum Log {
        static let title = "How are you feeling?"
        static let subtitle = "Tap the emotions that resonate with you right now"
        static let searchPlaceholder = "Search emotions"
        static let expandAll = "Expand All"
        static let collapseAll = "Collapse All"
        static let intensityTitle = "How strongly?"
        static let notePlaceholder = "Add a note... (optional)"
        static let saveCheckIn = "Save Check-in"
        static let cancel = "Cancel"
        static let savedToast = "Check-in saved ✦"
        static let freeLimitWarning = "You have %d free check-ins left this month."
        static let freeLimitReached = "You've reached your monthly limit. Upgrade to keep logging."
    }

    enum Zones {
        static let chargedName = "Charged & uneasy"
        static let brightName = "Bright & lively"
        static let steadyName = "Steady or mixed"
        static let heavyName = "Heavy & low"
        static let calmName = "Calm & settled"

        static let chargedDescription = "High energy, doesn't feel good"
        static let brightDescription = "High energy, feels good"
        static let steadyDescription = "In between, or a bit of both"
        static let heavyDescription = "Low energy, doesn't feel good"
        static let calmDescription = "Low energy, feels good"

        static let chargedExamples = "Anxious, stressed, angry"
        static let brightExamples = "Happy, excited, proud"
        static let steadyExamples = "Okay, torn, thoughtful"
        static let heavyExamples = "Sad, tired, numb"
        static let calmExamples = "Calm, safe, grateful"

        /// %1$@ = energy description, %2$@ = examples.
        static let accessibilityHint = "%1$@. For example: %2$@."
    }

    enum Insights {
        static let title = "Insights"
        static let radarTitle = "Chakra Balance"
        static let radarSubtitle = "Center = blocked · Middle = balanced · Outer = overactive"
        static let weeklySummary = "Weekly Summary"
        static let reflectionTitle = "Your weekly reflection"
        static let reflectionUnlock = "Unlock with Pro →"
        static let reflectionCaption = "Based on your check-ins from the last 7 days"
        static let recentCheckIns = "Recent Check-ins"
        static let emptyState = "Start logging to see your balance"
        static let timeline = "Mood Timeline"
        static let centersBreakdown = "Energy Centers"
    }

    enum Settings {
        static let title = "Settings"
        static let account = "Account"
        static let subscription = "Subscription"
        static let reminders = "Reminders"
        static let dataExport = "Data & Export"
        static let integrations = "Integrations"
        static let about = "About"
        static let exportJSON = "Export as JSON"
        static let exportPDF = "Export as PDF"
        static let openYggdrasil = "Open in Yggdrasil →"
        static let yggdrasilCaption = "Deep sync coming soon"
        static let privacy = "Privacy Policy"
        static let terms = "Terms of Use"
        static let rate = "Rate Anicca"
        static let deleteAccount = "Delete My Account"
        static let manageSubscription = "Manage Subscription"
        static let upgradeToPro = "Upgrade to Pro"
        static let reminderToggle = "Daily check-in reminder"
        static let proFeature = "Pro feature"
        static let signOut = "Sign Out"
    }

    enum Paywall {
        static let headline = "Unlock Your Full Pattern"
        static let subheadline = "Get weekly reflections, unlimited check-ins, and deeper self-awareness."
        static let monthly = "Monthly"
        static let annual = "Annual"
        static let saveBadge = "Save 33%"
        static let startPro = "Start Pro"
        static let getBundle = "Get the Bundle"
        static let restore = "Restore Purchases"
        static let renewalDisclosure = "Auto-renewing subscription. Payment is charged to your Apple Account at confirmation of purchase. Your subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your App Store settings."
        static let plansUnavailable = "Plans can't be loaded right now. Check your connection and try again."
        static let retry = "Retry"
        static let purchaseCancelled = "Purchase cancelled."
        static let networkError = "Check your connection and try again."
        static let purchaseFailed = "Purchase failed. Please try again."
        static let restoreSuccess = "Purchases restored."
        static let nothingToRestore = "No previous purchases found."
    }

    enum Errors {
        static let generic = "Something went wrong. Please try again."
        static let network = "We can't reach the network right now."
        static let auth = "We couldn't sign you in. Please check your credentials."
    }
}
