import { type ListItem } from '../LocalizedStrings/UIStringsTypes';

type NumberedListProps = {
    listItems: ListItem[],
}

export function NumberedList({ listItems } : NumberedListProps)
{
    return (
        <ol>
            {listItems.map((li: ListItem) => {
                return (
                    <li key={li.Key}>{li.Text}</li>
                );
            })}
        </ol>
    );
}