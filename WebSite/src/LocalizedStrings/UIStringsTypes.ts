export class ListItem {
    private static nextKey = 0;

    readonly Key: number;
    readonly Text: string;

    constructor(text: string)
    {
        this.Key = ListItem.GetNextKey();
        this.Text = text;
    }

    private static GetNextKey() : number
    {
        const nextKey = ListItem.nextKey;
        ListItem.nextKey++;
        return nextKey;
    }
}

export type MetricProperty = {
    readonly PropertyName: string;
    readonly PropertyValue: string;
}

export type ExplainGoalsSection = {
    readonly Header: string;

    readonly Paragraph_1_Start: string;
    readonly Paragraph_1_HowAUserUsesGoalsListItems: ListItem[];

    readonly Paragraph_2_Start: string;
    readonly Paragraph_2_ExampleGoalTableRow1Column1: string;
    readonly Paragraph_2_ExampleGoalTableRow1Column2: string;
    readonly Paragraph_2_AfterTable: string;
}

export type UseMetricsToTrackProgressSection = {
    readonly Header: string;

    readonly Paragraph_1: string;

    readonly Paragraph_2_Start: string;
    readonly Paragraph_2_ExampleWeightMetric: MetricProperty[];
    readonly Paragraph_2_ExampleFoodTrackingMetric: MetricProperty[];
}

export type LearnSection = {
    readonly Header: string;
    readonly Paragraph_1: string;
    readonly Paragraph_1_HowGoalsHelpsYouLearnListItems: ListItem[];
}

export type CreateAccountSection = {
    readonly Header: string;
    readonly Paragraph_1: string;
}

export type ProductionExplanationPage = {
    readonly ExplainGoalsSection: ExplainGoalsSection;
    readonly UseMetricsToTrackProgressSection: UseMetricsToTrackProgressSection;
    readonly LearnSection: LearnSection;
    readonly CreateAccountSection: CreateAccountSection;
    readonly CreateAccountButtonLabel: string;
}

export type UIStrings = { 
    readonly ApplicationName : string;
    readonly SignInButtonLabel : string;
    readonly ProductionExplanationPage: ProductionExplanationPage;
}
