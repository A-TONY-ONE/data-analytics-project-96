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
        ROW_NUMBER()
            over (partition by sessions.visitor_id order by visit_date desc)
        as rn
    from sessions
    left join leads
        on sessions.visitor_id = leads.visitor_id
        and visit_date <= created_at
    where medium  <> 'organic'
)

select
    tab.visitor_id,
    tab.visit_date,
    tab.source as utm_source,
    tab.medium as utm_medium,
    tab.campaign as utm_campaign,
    tab.created_at,
    tab.amount,
    tab.closing_reason,
    tab.status_id
from tab
where tab.rn = 1
order by
    tab.amount desc nulls last,
    tab.visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
