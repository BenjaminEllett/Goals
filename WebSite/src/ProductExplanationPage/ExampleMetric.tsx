import { type MetricProperty } from '../LocalizedStrings/UIStringsTypes';

type ExampleMetricProps = {
    metricProperties: MetricProperty[],
}

export function ExampleMetric({ metricProperties } : ExampleMetricProps)
{
    return (
        <table>
            <tbody>
                { metricProperties.map((mp: MetricProperty) => {
                    return (
                        <tr key={mp.PropertyName}>
                            <th scope="row">{mp.PropertyName}</th>
                            <td className='example-metric-metric-description-width'>{mp.PropertyValue}</td>
                        </tr>
                    )
                })}
            </tbody>
        </table>
    );
}