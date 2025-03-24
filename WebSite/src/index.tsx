import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client';
import { ProductExplanation } from './ProductExplanationPage/ProductExplanation';
import { NavigationBar } from './NavigationBar';

const DEBUG = true;

function FrontPage()
{
    return (
        <>
            <NavigationBar />
            <ProductExplanation />
        </>
    );
}

function DebugFrontPage()
{
    return (
        <StrictMode >
            <NavigationBar />
            <ProductExplanation />
        </StrictMode>
    );
}

const appHtmlElementDomNode = document.getElementById('AppRoot');
if (null === appHtmlElementDomNode)
{
    throw new Error('This error should never occur.');
}

const appRoot = createRoot(appHtmlElementDomNode);

if (DEBUG)
{
    appRoot.render(<DebugFrontPage />);
}
else
{
    appRoot.render(<FrontPage />);
}
