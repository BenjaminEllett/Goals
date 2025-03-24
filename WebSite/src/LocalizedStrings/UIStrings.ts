import { type UIStrings } from "./UIStringsTypes";
import { usEnglishStrings } from './en-US';

function DetermineUIStrings() : UIStrings
{
    for (const currentLanguage of navigator.languages)
    {
        switch (currentLanguage)
        {
            case 'en-US':
                return usEnglishStrings;

            default:
                break;
        }
    }

    // Default to English strings if the current language is not supported.
    return usEnglishStrings;
}

export const uiStrings : UIStrings = DetermineUIStrings();