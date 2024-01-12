with sessions_leads as (
    select
        sessions.visitor_id,
        visit_date,
        source as utm_source,
        medium as utm_medium,
        campaign as utm_campaign,
        created_at,
        amount,
        closing_reason,
        status_id,
        lead_id,
        ROW_NUMBER()
            over (partition by sessions.visitor_id order by visit_date desc)
            as rn
    from sessions
    left join leads
        on
            sessions.visitor_id = leads.visitor_id
            and visit_date <= created_at
    where medium != 'organic'
),

revenue_vk_ads_ya_ads as (
    select
        DATE_TRUNC('day', visit_date) as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        COUNT(visitor_id) as visitors_count,
        SUM(case when lead_id is not null then 1 else 0 end) as leads_count,
        SUM(
            case
                when
                    closing_reason = 'Успешная продажа' or status_id = 142
                    then 1
                else 0
            end
        ) as purchases_count,
        SUM(amount) as revenue,
        null as total_cost
    from sessions_leads
    where sessions_leads.rn = 1
    group by
        visit_date,
        utm_source,
        utm_medium,
        utm_campaign
    union all

    select
        campaign_date as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        null as revenue,
        null as visitors_count,
        null as leads_count,
        null as purchases_count,
        daily_spent as total_cost
    from vk_ads
    union all
    select
        campaign_date as visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        null as revenue,
        null as visitors_count,
        null as leads_count,
        null as purchases_count,
        daily_spent as total_cost
    from ya_ads
)

select
    utm_source,
    utm_medium,
    utm_campaign,
    TO_CHAR(visit_date, 'YYYY-MM-DD') as visit_date,
    SUM(visitors_count) as visitors_count,
    SUM(total_cost) as total_cost,
    SUM(leads_count) as leads_count,
    SUM(purchases_count) as purchases_count,
    SUM(revenue) as revenue
from revenue_vk_ads_ya_ads
group by
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign
order by
    revenue desc nulls last,
    visit_date asc,
    visitors_count desc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
limit 10;
