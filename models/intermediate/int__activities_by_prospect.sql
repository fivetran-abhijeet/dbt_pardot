with activities as (

    select *
    from {{ var('visitor_activity') }}

), visitors as (

    select *
    from {{ var('visitor') }}

), joined as (

    select
        activities.event_type_name,
        activities.created_timestamp,
        coalesce(visitors.prospect_id, activities.prospect_id) as prospect_id
    from activities
    left join visitors
        using (visitor_id)

), aggregated as (

    select 
        prospect_id,
        count(case when event_type_name = 'Visit' then 1 end) as count_activity_visits,
        max(case when event_type_name = 'Visit' then created_timestamp end) as most_recent_visit_activity_timestamp,
        count(case when event_type_name = 'Email' then 1 end) as count_activity_emails,
        max(case when event_type_name = 'Email' then created_timestamp end) as most_recent_email_activity_timestamp
    from joined
    group by 1

)

select *
from aggregated