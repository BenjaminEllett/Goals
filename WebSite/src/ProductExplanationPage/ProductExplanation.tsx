import { uiStrings } from '../LocalizedStrings/UIStrings';
import { CreateAccountButton } from './CreateAccountButton';
import { ExampleMetric } from './ExampleMetric';
import { NumberedList } from './NumberedList';

export function ProductExplanation()
{
    const explainGoalsSection = uiStrings.ProductionExplanationPage.ExplainGoalsSection;
    const useMetricsToTrackProgressSection = uiStrings.ProductionExplanationPage.UseMetricsToTrackProgressSection;
    const learnSection = uiStrings.ProductionExplanationPage.LearnSection;
    const createAccountSection = uiStrings.ProductionExplanationPage.CreateAccountSection;

    return (
        <main className='product-explanation-container'>
            {/* Section - Explain what Goals is */}
            <section className='production-explanation-section'>
                <h1 className='centered-header'>{explainGoalsSection.Header}</h1>
                <p>{explainGoalsSection.Paragraph_1_Start}</p>
                <NumberedList listItems={explainGoalsSection.Paragraph_1_HowAUserUsesGoalsListItems} />
                
                <p className='space-before-paragraph'>{explainGoalsSection.Paragraph_2_Start}</p>
                <table>
                    <tbody>
                        <tr>
                            <th scope="row">{explainGoalsSection.Paragraph_2_ExampleGoalTableRow1Column1}</th>
                            <td>{explainGoalsSection.Paragraph_2_ExampleGoalTableRow1Column2}</td>
                        </tr>
                    </tbody>
                </table>
                <p>{explainGoalsSection.Paragraph_2_AfterTable}</p>
            </section>

            {/* Section - Introduce metrics and explain how they help users achieve complex goals */}
            <section className='production-explanation-section'>
                <h1 className='centered-header'>{useMetricsToTrackProgressSection.Header}</h1>
                <p className='space-before-paragraph'>{useMetricsToTrackProgressSection.Paragraph_1}</p>
                <p className='space-before-paragraph'>{useMetricsToTrackProgressSection.Paragraph_2_Start}</p>
                <ExampleMetric metricProperties={useMetricsToTrackProgressSection.Paragraph_2_ExampleWeightMetric} />
                <ExampleMetric metricProperties={useMetricsToTrackProgressSection.Paragraph_2_ExampleFoodTrackingMetric} />
            </section>

            {/* Section - Explain how Goals helps you learn as you pursue your goals */}
            <section className='production-explanation-section'>
                <h1 className='centered-header'>{learnSection.Header}</h1>
                <p>{learnSection.Paragraph_1}</p>
                <NumberedList listItems={learnSection.Paragraph_1_HowGoalsHelpsYouLearnListItems} />
            </section>

            {/* Section - Create account section */}
            <section className='production-explanation-section'>
                <h1 className='centered-header'>{createAccountSection.Header}</h1>
                <p>{createAccountSection.Paragraph_1}</p>
                <div className='create-account-button-container'>
                    <CreateAccountButton/>
                </div>
            </section>
        </main>
    );
}