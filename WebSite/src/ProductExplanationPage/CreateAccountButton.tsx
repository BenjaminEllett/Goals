import { uiStrings } from '../LocalizedStrings/UIStrings';

export function CreateAccountButton()
{
    return (
        <button type='button' 
                className='create-account-button'>{uiStrings.ProductionExplanationPage.CreateAccountButtonLabel}</button>
    );
}