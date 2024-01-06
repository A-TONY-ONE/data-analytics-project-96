with tab as (
    select
        sessions.visitor_id,
        visit_date,
        source,
        medium,
        campaign,
        created_at,
        amount,
        closing_reason,
        status_id,
        case
            when created_at < visit_date then 'invalid' else lead_id
        end as lead_id,
        ROW_NUMBER()
            over (partition by sessions.visitor_id order by visit_date desc)
        as rn
    from sessions
    left join leads
        on sessions.visitor_id = leads.visitor_id
    where medium  <> 'organic'
)

select
    tab.visitor_id,
    tab.visit_date,
    tab.source as utm_source,
    tab.medium as utm_medium,
    tab.campaign as utm_campaign,
    case
        when tab.created_at < tab.visit_date then 'invalid' else lead_id
    end as lead_id,
    tab.created_at,
    tab.amount,
    tab.closing_reason,
    tab.status_id
from tab
where (tab.lead_id != 'invalid' or tab.lead_id is null) and tab.rn = 1
order by
    tab.amount desc nulls last,
    tab.visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
