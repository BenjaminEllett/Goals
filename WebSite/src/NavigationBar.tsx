import { uiStrings } from './LocalizedStrings/UIStrings';

export function NavigationBar()
{
    return (
        <nav className='navigation-bar'>
            <button type='button' className='go-to-main-page-button'>{uiStrings.ApplicationName}</button>
            <button type='button' className='sign-in-button'>{uiStrings.SignInButtonLabel}</button>
        </nav>
    )
}
