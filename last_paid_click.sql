SELECT 
    visitor_id,
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign,
    lead_id,
    created_at,
    amount,
    closing_reason,
    status_id
FROM 
    attribution_data
WHERE 
    utm_source IN ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social') AND
    lead_id IS NOT NULL AND
    created_at IS NOT NULL AND
    amount IS NOT NULL AND
    closing_reason IS NOT NULL AND
    status_id IS NOT NULL
ORDER BY 
    amount DESC,
    visit_date ASC,
    utm_source ASC,
    utm_medium ASC,
    utm_campaign ASC