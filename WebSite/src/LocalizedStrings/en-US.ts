import { type UIStrings, type MetricProperty, ListItem } from "./UIStringsTypes";

const HowAUserUsesGoalsListItems = [
    new ListItem("You create goals"),
    new ListItem("For each goal, you can create metrics to help track your progress"),
    new ListItem("You periodically review goals, log metric values, and record lessons learned"),
    new ListItem("You gradually achieve your goals!")
];

const HowGoalsHelpsYouLearnListItems = [
    new ListItem("You learn something about your goal.  For example, you might notice that you eat an entire bag of potato chips as soon as you buy it.  You learn that you can avoid overeating by only buying one small bag of potato chips at a time."),
    new ListItem("You create a lessoned learned under your Goal.  The lesson learned is something like \"I will prevent myself from overeating chips by buying one small bag of chips a week.  Even if I overeat, I will still not gain weight because the bag is small and I am only eating one bag a week.\""),
    new ListItem("Goals periodically shows you the lessoned learned.  This helps you remember what you have learned and helps you achieve your goals."),
    new ListItem("You can edit, delete, manage, or suppress, lessons learned.  Suppressed lessons learned are not periodically shown to you.")
];

const ComplexExampleWeightMetric : MetricProperty[] = [
    { PropertyName: "Metric Name", PropertyValue: "Weight" },
    { PropertyName: "Description", PropertyValue: "My body's weight in pounds (lbs). It's measure every Sunday night." },  
    { PropertyName: "Allowed Values", PropertyValue: "Any positive integer (a number with no decimal point)" },
    { PropertyName: "Units", PropertyValue: "Pounds (lbs)" },
    { PropertyName: "Target Value", PropertyValue: "160" },
    { PropertyName: "Measurement Period", PropertyValue: "Weekly" },
    { PropertyName: "Measurement Day", PropertyValue: "Monday" },    
];

const ComplexExampleFoodTrackingMetric : MetricProperty[] = [
    { PropertyName: "Metric Name", PropertyValue: "Tracked eating habits" },
    { PropertyName: "Description", PropertyValue: "Did I track everything I ate in my food tracking app?"},  
    { PropertyName: "Allowed Values", PropertyValue: "An integer between 1 and 7" },
    { PropertyName: "Units", PropertyValue: "Times" },
    { PropertyName: "Measurement Period", PropertyValue: "Weekly" },
    { PropertyName: "Measurement Frequency", PropertyValue: "Daily" },
    { PropertyName: "Measurement Aggregation Function", PropertyValue: "Sum" },
];

export const usEnglishStrings : UIStrings = {
    ApplicationName: "Goals",
    SignInButtonLabel: "Sign In",

    ProductionExplanationPage: {
        ExplainGoalsSection: {
            Header: "Achieve your goals",

            Paragraph_1_Start: "Goals helps you set, track, and achieve your goals.  Here is how it works:",
            Paragraph_1_HowAUserUsesGoalsListItems: HowAUserUsesGoalsListItems,

            Paragraph_2_Start: "Here is an example.  Say you want to lose weight.  You could create a goal like the following goal:",
            Paragraph_2_ExampleGoalTableRow1Column1: "Goal Name",
            Paragraph_2_ExampleGoalTableRow1Column2: "Get to a healthy weight",
            Paragraph_2_AfterTable: "That's it!  You can now periodically review your goals to remind yourself of them and mark them as complete when you reach them.",
        },

        UseMetricsToTrackProgressSection: {
            Header: "Track progress with metrics",

            Paragraph_1: "For hard goals, you need to track your progress, and you need to learn from your mistakes and setbacks.  Goals helps you with both of these.  It does this by allowing you to create metrics and lessons learned.",

            Paragraph_2_Start: "Metrics help you measure your progress.  They help you see what you have done and how far you have to go to achieve a goal.  Here are some example metrics you could create for the weight loss goal:",
            Paragraph_2_ExampleWeightMetric: ComplexExampleWeightMetric,
            Paragraph_2_ExampleFoodTrackingMetric: ComplexExampleFoodTrackingMetric
        },

        LearnSection: {
            Header: "Learn as you go",
            Paragraph_1: "You will learn as you work on your goals.  Goals helps you record and remembers these lessons.  Here is how it does this:",
            Paragraph_1_HowGoalsHelpsYouLearnListItems: HowGoalsHelpsYouLearnListItems
        },

        CreateAccountSection: {
            Header: "Ready to reach you goals?",
            Paragraph_1: "If you are, click on the Create Account button to get started!"
        },

        CreateAccountButtonLabel: "Create Account"
    }
}